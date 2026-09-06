"""
DrugShield ML Pipeline — INT8 Full Integer Quantization Script
SIH26231: Digital Companion for Field Drug Testing

Converts trained Keras model to Google LiteRT INT8 Quantized model
using Representative Dataset Calibration for low-latency on-device inference.
"""

import os
import numpy as np
import tensorflow as tf
from dataset_curator import create_dataset_batch

def representative_dataset_gen():
    """Calibration dataset for INT8 quantization dynamic range estimation."""
    calib_images, _ = create_dataset_batch(num_samples_per_class=20)
    for img in calib_images:
        # Preprocess to float32 input shape [1, 224, 224, 3]
        sample = np.expand_dims(img.astype(np.float32), axis=0)
        yield [sample]

def quantize_to_int8(keras_model_path="models/drugshield_mobilenet_v3.keras", output_tflite_path="../apps/mobile/assets/models/mobilenet_v3_int8.tflite"):
    print(f"📦 [DrugShield ML] Quantizing {keras_model_path} to INT8 LiteRT...")

    os.makedirs(os.path.dirname(output_tflite_path), exist_ok=True)

    if os.path.exists(keras_model_path):
        model = tf.keras.models.load_model(keras_model_path)
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
    else:
        # Build functional graph directly if pre-saved keras model is not yet generated
        from train_mobilenet_v3 import build_mobilenet_v3_model
        model = build_mobilenet_v3_model()
        converter = tf.lite.TFLiteConverter.from_keras_model(model)

    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset = representative_dataset_gen
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type = tf.uint8
    converter.inference_output_type = tf.uint8

    tflite_quant_model = converter.convert()

    with open(output_tflite_path, "wb") as f:
        f.write(tflite_quant_model)

    size_mb = len(tflite_quant_model) / (1024 * 1024)
    print(f"✅ [DrugShield ML] INT8 Quantized model successfully generated: {output_tflite_path} ({size_mb:.2f} MB)")

if __name__ == "__main__":
    quantize_to_int8()
