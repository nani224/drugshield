"""
DrugShield ML Pipeline — MobileNetV3-Large Transfer Learning Training Script
SIH26231: Digital Companion for Field Drug Testing

Trains MobileNetV3-Large with Squeeze-and-Excitation (SE) blocks on
calibrated colorimetric drug pouch images.
"""

import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from dataset_curator import create_dataset_batch

def build_mobilenet_v3_model(num_classes=6, input_shape=(224, 224, 3)):
    """Builds MobileNetV3-Large backbone with lightweight classification head."""
    base_model = tf.keras.applications.MobileNetV3Large(
        input_shape=input_shape,
        include_top=False,
        weights="imagenet",
        pooling="avg",
        minimalistic=False,
        include_preprocessing=True
    )

    # Freeze base model weights initially for transfer learning
    base_model.trainable = False

    inputs = keras.Input(shape=input_shape, name="input_image")
    x = base_model(inputs, training=False)
    x = layers.Dropout(0.3)(x)
    x = layers.Dense(128, activation=layers.Activation("hard_swish"), name="feature_dense")(x)
    x = layers.Dropout(0.2)(x)
    outputs = layers.Dense(num_classes, activation="softmax", name="substance_probs")(x)

    model = keras.Model(inputs=inputs, outputs=outputs, name="drugshield_mobilenet_v3")
    return model

def train_and_export():
    print("🚀 [DrugShield ML] Generating colorimetric training dataset...")
    X_train, y_train = create_dataset_batch(num_samples_per_class=150)
    X_val, y_val = create_dataset_batch(num_samples_per_class=30)

    model = build_mobilenet_v3_model(num_classes=6)
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=1e-3),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"]
    )

    print("🧠 [DrugShield ML] Fine-tuning MobileNetV3-Large...")
    model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=5,
        batch_size=32,
        verbose=1
    )

    os.makedirs("models", exist_ok=True)
    save_path = "models/drugshield_mobilenet_v3.keras"
    model.save(save_path)
    print(f"✅ Model saved to {save_path}")
    return model

if __name__ == "__main__":
    train_and_export()
