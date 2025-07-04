# TFG: Implementació d'un joc de combat de drons amb Flutter, Node.js i Python

Aquest projecte és una aplicació Flutter per a la competició i control en temps real de drons. 


## Taula de continguts

1. [Requisits previs](#requisits-previs)   
2. [Configuració de l’entorn](#configuració-de-lentorn)  
3. [Variables d’entorn (`.env`)](#variables-dentorn-env)  
4. [Instal·lació de dependències](#instal·lació-de-dependències)  
5. [Executar l’aplicació](#executar-laplicació)  
6. [Vídeos](#vídeos)  
7. [Referències](#referències)  


## Requisits previs

- **Flutter SDK** ≥ 3.0  
- **Editor** VS Code  
- **Ngrok** per a túnels locals


## Configuració de l’entorn

Crea un fitxer `.env` a la carpeta arrel que contingui el següent:  

### URL pùblica de la teva API (ngrok tunnel cap al port 9000) + /api
SERVER_URL=https://XXXX.ngrok-free.app/api

ADMIN_KEY=profe1234


DRON_ROJO_EMAIL=dron_rojo1@upc.edu

DRON_ROJO_PASSWORD=Dron_rojo1*


DRON_AZUL_EMAIL=dron_azul1@upc.edu

DRON_AZUL_PASSWORD=Dron_azul1*


DRON_VERDE_EMAIL=dron_verde1@upc.edu

DRON_VERDE_PASSWORD=Dron_verde1*


DRON_AMARILLO_EMAIL=dron_amarillo1@upc.edu

DRON_AMARILLO_PASSWORD=Dron_amarillo1*


GOOGLE_MAPS_API_KEY=AIzaSyB3kZh-VYxXIJXrNhZKX-KjiXFGQIbM2LI


## Instal·lació de dependències

Des de la carpeta arrel del projecte, executa: flutter pub get

Això instal·larà:
    socket_io_client
    flutter_map
    flutter_joystick
    go_router
    flutter_dotenv
    http
    i altres utilitats de Flutter.


## Executar l’aplicació

flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080


## Vídeos

Enllaç del vídeo de funcionament:
Enllaç del vídeo del recorregut pel codi:


## Referències

Algunes webs amb material de disseny per Flutter:

[1] https://docs.flutter.dev/ui/navigation

[2] https://docs.flutter.dev/ui/widgets/material

[3] https://docs.flutter.dev/ui/widgets/layout

[4] https://m3.material.io/

[5] https://pub.dev/packages/http#