"""
DrugShield ML Pipeline — Colorimetric Dataset Curator & Augmentor
SIH26231: Digital Companion for Field Drug Testing

Generates and augments colorimetric test samples across 5 standard presumptive reagents:
  1. Scott / Cobalt Thiocyanate Reagent: Cocaine HCl / Crack (Turquoise Blue)
  2. Mecke Reagent: Heroin / Morphine (Deep Blue-Green)
  3. Marquis Reagent: Opioids / MDMA / Amphetamines (Purple to Black / Orange)
  4. Mandelin Reagent: Methadone / Amphetamines (Olive Green to Dark Brown)
  5. Duquenois-Levine Reagent: Cannabis / THC (Violet-Indigo)
  6. Negative / Adulterant / Inconclusive Control (No Color Change / Amber-Yellow)
"""

import os
import math
import numpy as np

# Standard spectral chromaticity centroids in CIE L*a*b* for calibrated reagent reactions
REAGENT_SPECTRUM_PROFILES = {
    0: {
        "name": "Cocaine HCl / Crack Cocaine",
        "reagent": "Scott / Cobalt Thiocyanate Reagent",
        "lab_centroid": (58.0, -18.5, -42.0), # Intense Turquoise Blue
        "std_dev": (4.5, 3.2, 5.0),
    },
    1: {
        "name": "Heroin / Morphine",
        "reagent": "Mecke Reagent",
        "lab_centroid": (44.0, -28.0, 6.0),   # Deep Blue-Green
        "std_dev": (3.8, 4.0, 3.5),
    },
    2: {
        "name": "Opioids / Amphetamines / MDMA",
        "reagent": "Marquis Reagent",
        "lab_centroid": (28.0, 18.0, -14.0),  # Deep Purple to Black
        "std_dev": (4.0, 3.5, 4.2),
    },
    3: {
        "name": "Methadone / Amphetamines",
        "reagent": "Mandelin Reagent",
        "lab_centroid": (38.0, -12.0, 24.0),  # Olive Green to Dark Brown
        "std_dev": (3.5, 3.0, 4.0),
    },
    4: {
        "name": "Cannabis / THC / Hashish",
        "reagent": "Duquenois-Levine Reagent",
        "lab_centroid": (42.0, 32.0, -22.0),  # Violet-Indigo layer
        "std_dev": (4.2, 4.5, 3.8),
    },
    5: {
        "name": "Negative / Adulterant / Inconclusive",
        "reagent": "Unreacted / Negative Control",
        "lab_centroid": (78.0, -2.0, 8.0),    # Clear / Translucent light amber
        "std_dev": (3.0, 2.0, 3.0),
    }
}

def lab_to_rgb(L, a, b):
    """Converts CIE L*a*b* coordinates (D65 standard) to standard RGB (0-255)."""
    y = (L + 16.0) / 116.0
    x = a / 500.0 + y
    z = y - b / 200.0

    def f_inv(t):
        delta = 6.0 / 29.0
        if t > delta:
            return t ** 3
        else:
            return 3 * (delta ** 2) * (t - 4.0 / 29.0)

    # Reference white point D65
    Xn, Yn, Zn = 95.0489, 100.000, 108.8840
    X = Xn * f_inv(x) / 100.0
    Y = Yn * f_inv(y) / 100.0
    Z = Zn * f_inv(z) / 100.0

    # Linear sRGB transformation matrix
    r_lin = 3.2406 * X - 1.5372 * Y - 0.4986 * Z
    g_lin = -0.9689 * X + 1.8758 * Y + 0.0415 * Z
    b_lin = 0.0557 * X - 0.2040 * Y + 1.0570 * Z

    def gamma_correct(c):
        c = max(0.0, min(1.0, c))
        if c > 0.0031308:
            return 1.055 * (c ** (1.0 / 2.4)) - 0.055
        else:
            return 12.92 * c

    r = int(round(gamma_correct(r_lin) * 255.0))
    g = int(round(gamma_correct(g_lin) * 255.0))
    b = int(round(gamma_correct(b_lin) * 255.0))

    return np.clip([r, g, b], 0, 255).astype(np.uint8)

def generate_synthetic_sample(class_idx, img_size=224):
    """Generates an augmented test sample image simulating pouch reaction well with illumination noise."""
    profile = REAGENT_SPECTRUM_PROFILES[class_idx]
    mean_lab = profile["lab_centroid"]
    std_lab = profile["std_dev"]

    # Sample randomized CIE L*a*b* with Gaussian variance
    L = np.random.normal(mean_lab[0], std_lab[0])
    a = np.random.normal(mean_lab[1], std_lab[1])
    b = np.random.normal(mean_lab[2], std_lab[2])

    base_rgb = lab_to_rgb(L, a, b)

    # Create synthetic image canvas with central circular well and plastic pouch background
    img = np.zeros((img_size, img_size, 3), dtype=np.float32)

    # Pouch background color: slate #1A2230
    pouch_bg = np.array([26.0, 34.0, 48.0], dtype=np.float32)
    img[:, :] = pouch_bg

    center = (img_size // 2, img_size // 2)
    radius = img_size * 0.38

    y_indices, x_indices = np.ogrid[:img_size, :img_size]
    dist_from_center = np.sqrt((x_indices - center[0]) ** 2 + (y_indices - center[1]) ** 2)

    # Fill reaction well with gradient & noise
    well_mask = dist_from_center <= radius
    noise = np.random.normal(0, 4.0, (img_size, img_size, 3))

    for c in range(3):
        # Radial vignette inside reaction well
        vignette = 1.0 - (dist_from_center / radius) * 0.25
        well_color = base_rgb[c] * vignette + noise[:, :, c]
        img[:, :, c] = np.where(well_mask, well_color, img[:, :, c])

    # Add simulated ambient lighting bias (streetlights or sun glare)
    illumination_bias = np.random.uniform(-15.0, 15.0, 3)
    img = np.clip(img + illumination_bias, 0, 255).astype(np.uint8)

    return img

def create_dataset_batch(num_samples_per_class=100, img_size=224):
    """Generates a balanced dataset of augmented samples across all classes."""
    images = []
    labels = []

    for class_idx in sorted(REAGENT_SPECTRUM_PROFILES.keys()):
        for _ in range(num_samples_per_class):
            img = generate_synthetic_sample(class_idx, img_size)
            images.append(img)
            labels.append(class_idx)

    return np.array(images, dtype=np.uint8), np.array(labels, dtype=np.int32)

if __name__ == "__main__":
    X, y = create_dataset_batch(10)
    print(f"Dataset generated: {X.shape} samples across {len(np.unique(y))} classes.")
