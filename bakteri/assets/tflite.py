import tensorflow as tf
import tf2onnx

# TensorFlow Lite modelini yükle
tflite_model_path = "model.tflite"

# TensorFlow modelini yükle
converter = tf.lite.TFLiteConverter.from_saved_model(tflite_model_path)
tf_model = converter.convert()

# ONNX formatına çevir
onnx_model_path = "model.onnx"
tf2onnx.convert.from_function(tf_model, output_path=onnx_model_path)

print(f"✅ Model {onnx_model_path} olarak kaydedildi!")
