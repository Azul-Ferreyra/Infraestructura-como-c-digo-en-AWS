# Laboratorio SOC con Terraform en AWS

Este laboratorio fue preparado para la **convención KAVACON Paraguay** y tiene como objetivo enseñar cómo utilizar **Terraform** para desplegar un SOC en AWS de forma segura y automatizada.

> ⚠️ Nota: En mi versión original, **instalé Nginx y Wazuh manualmente** una vez creadas las instancias. En este repositorio, el código incluye `user_data` para que la instalación sea automática.

---

## Objetivos del laboratorio

- Levantar una infraestructura de seguridad real en AWS utilizando **Infraestructura como Código (IaC)**.
- Enseñar el uso de **roles diferenciados**:
  - **Analista SOC:** ingresa a través de un **proxy inverso (NGINX)** a la consola gráfica de Wazuh.
  - **DevSecOps:** acceso seguro a las instancias por **SSM**, sin exponer puertos innecesarios.
- Demostrar la creación de infraestructura **repetible y segura** usando Terraform.

---

## Requisitos previos

- Usuario de AWS con permisos suficientes.
- [Terraform](https://www.terraform.io/) instalado.
- [AWS CLI](https://aws.amazon.com/cli/) instalado y configurado. 
- Conocimientos básicos de redes y seguridad en la nube.

---

## Arquitectura de la infraestructura

- **VPC** con dos subredes:
  - **Subred pública:** servidor NGINX (reverse proxy)
  - **Subred privada:** SOC con Wazuh
- **Internet Gateway** y **NAT Gateway** para control de tráfico.
- **Security Groups** estrictos para controlar el acceso.
- **SSM (Systems Manager)** para administración segura de instancias.
- **Roles diferenciados** para acceso seguro:
  - Proxy inverso para analistas SOC.
  - Acceso SSM para DevSecOps.

---

## Tecnologías utilizadas

- **Terraform:** automatiza la creación y gestión de la infraestructura.
- **AWS:** proveedor de servicios cloud.
- **Nginx:** servidor web y reverse proxy.
- **Wazuh:** plataforma de seguridad (SIEM / XDR).
- **SSM:** administración segura de instancias sin exponer puertos.

---

## Instalación y despliegue

### 1. Inicializar Terraform

 ```bash
terraform init


2. Generar plan de ejecución
terraform plan

3. Aplicar la infraestructura
terraform apply

4. Eliminar la infraestructura (cuando sea necesario)
terraform destroy


Notas sobre AMIs


Deben seleccionar una AMI adecuada para Ubuntu (24.04 recomendado).


En este laboratorio, se usaron copias de AMIs de instancias con Nginx y Wazuh ya instalados.


En el código se incluyen ejemplos de user_data para instalar Nginx y Wazuh automáticamente.



Principios de seguridad aplicados


Uso de SSM para acceso remoto seguro.


Subred privada para Wazuh y pública solo para el proxy.


Gestión de credenciales sensible a través de AWS.


Control de tráfico con Security Groups y roles diferenciados.



Recursos adicionales


Video completo de la conferencia: KAVACON Paraguay https://www.youtube.com/live/CWywWZAhbCs?si=fbYF7E_xV5gLfWpa


Documentación oficial de Terraform  https://developer.hashicorp.com/terraform


Documentación oficial de AWS       https://signin.aws.amazon.com/


Sígueme en mis redes para más contenido sobre ciberseguridad y cloud.



Conclusión
Este laboratorio permite:


Implementar infraestructura segura y automatizada en AWS.


Aprender buenas prácticas de IaC.


Experimentar con roles diferenciados y acceso seguro a servicios críticos.


Escalar y reproducir un SOC de manera eficiente y segura.

LABORATORIO REALIZADO POR AZUL ROCIO FERREYRA / ANZUR 12/11/2025