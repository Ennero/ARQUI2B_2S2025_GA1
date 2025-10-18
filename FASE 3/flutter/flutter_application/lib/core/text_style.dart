import 'package:flutter/material.dart';

class TextStyles {
  /// Estilo para títulos muy grandes y destacados.
  /// Uso: Nombres de usuario en perfiles, saludos principales.
  static const TextStyle displayLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  /// Estilo para encabezados y títulos de secciones.
  /// Uso: Nombres en las listas de chat, títulos de tarjetas.
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600, // Semi-bold
  );

  /// Estilo para el cuerpo de texto principal.
  /// Uso: Previsualización de mensajes en la lista de chats.
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
  );

  /// Estilo para texto secundario y metadatos.
  /// Uso: Marcas de tiempo, información de estado.
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
  );

  /// Estilo para el texto dentro de botones.
  /// Uso: Botones de acción principales.
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  /// Estilo alternativo para texto de acento.
  /// Uso: Texto que necesita destacar con el color principal de la marca.
  static const TextStyle accentText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
  );
}