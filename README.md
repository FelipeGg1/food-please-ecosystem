# FoodPlease - Sistema Integral de Pedidos

Bienvenido al repositorio de **FoodPlease**, una solución completa para la gestión de pedidos en restaurantes. Este proyecto implementa una arquitectura moderna separando la lógica de negocio y administración (Web) de la experiencia del cliente (Móvil).

## Arquitectura del Proyecto

El sistema funciona como un Monorepo dividido en dos grandes componentes:

1.  **Portal Web & API (Backend):**
    * Desarrollado en **Django 5**.
    * Funciona como Portal de Administración para el restaurante (crear menús, platos, ver pedidos).
    * Expone una REST API (vía **Django Rest Framework**) para alimentar la app móvil.
    * Ejecutado sobre **Docker** para un entorno aislado y limpio.

2.  **App Móvil (Frontend):**
    * Desarrollada en **Flutter**.
    * Permite a los clientes ver el menú, agregar productos al carrito y realizar pedidos.
    * Incluye historial de pedidos y gestión de estado local.

---

## Tecnologías Utilizadas

* **Lenguajes:** Python 3.10, Dart.
* **Frameworks:** Django, Django Rest Framework (DRF), Flutter.
* **Base de Datos:** SQLite (Desarrollo), SQL Server (Proyección a futuro).
* **Infraestructura:** Docker, Docker Compose.
* **Herramientas:** VS Code, Android Studio (Emulador).

---

## Pre-requisitos

Para correr este proyecto necesitas tener instalado:

* [Git](https://git-scm.com/)
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* Un editor de código (Recomendado: VS Code).

