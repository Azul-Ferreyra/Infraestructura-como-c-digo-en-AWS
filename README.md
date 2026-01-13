## Laboratorio SOC con Terraform en AWS
Este laboratorio fue preparado para la  **convencion KAVACON Paraguay** y tiene como objetivo enseñar como utilizar **TERRAFORM** para desplegar un SOC en AWS de forma segura y automatizada. 

**IMPORTANTE** En mi version original se implementa **Nginx & Wazuh** manualmente una vez creadas las instancias.  En este repositorio, el codigo incluye "USER_DATA" con el objetivo de que la instalacion sea de forma automatica. 

## Objetivos del Laboratorio
Levantar una infraestructura de seguridad real en AWS utilizando **Infraestructura como Codigo (IaC)**. 

Enseñar el uso de **Roles Diferenciados** .

El Analista SOC ingresara a traves de un proxy inverso (Nginx) a la consola grafica de Wazuh, mientras que el DevSecOps tendra acceso seguro a las instancias por medio de **SSM**, sin necesidad de exponer puertos innecesarios. 

Demostrar la creacion de infraestructura **replicable y segura** usando Terraform. 

## Requisitos Previos
- Usuario de AWS con permisos suficientes.
- [Terraform](https://www.terraform.io/) instalado.
- [AWS CLI](https://aws.amazon.com/cli/) instalado y configurado.
- Conocimientos basicos de redes y seguridad en la nube.

## Arquitectura de la Infraestructura 
- ** VPC** con dos subredes:
-  **Subred Publica** Servicio Nginx (reverse proxy)
-  **Subred Privada** SOC con Wazuh
-  **Internet Gateway** y **NAT Gateway** para control de trafico.
-  **Security Groups** estrictos para controlar el acceso.
-  **SSM (Systems Manager)** para administracion segura de instancias.
-  **Roles Diferenciados** para acceso seguro.

## Tecnologias Utilizadas 
-**Terraform** automatiza la creacion y gestion de la infraestructura.
**AWS** proveedor de servicios cloud.
**Nginx** servidor web y reverse proxy.
**Wazuh** plataforma de seguridad (siem/xdr).
**SSM** administracion segura de instancias sin exponer puertos. 


## Instalacion y despliegue 

## 1- Inicializar Terraform 
terraform init 

## 2- Generar plan de ejecucion
terraform plan

## 3- Aplicar la infraestructura 
terraform apply

## 4- Eliminar la infraestructura cuando sea necesario
terraform destroy

Notas sobre AMIs 
Debe seleccionar una AMI adecuada para Ubuntu (24.04 recomendado).

En este laboratorio se utilizaron copias de AMIs de instancias con Nginx y Wazuh ya instalados. 

En el codigo se incluye ejemplos de user_data para instalar Nginx y Wazuh automaticamente.

## Principios de Seguridad Aplicados
- Uso de **SSM** para acceso remoto seguro.
- Subredes privadas para Wazuh y publica unicamente para el proxy.
- Gestion de credenciales sensibles a traves de AWS.
- Control de trafico con Security Groups y roles diferenciados.

## Recursos Adicionales 

Video completo de la conferencia: KAVACON Paraguay https://www.youtube.com/live/CWywWZAhbCs?si=fbYF7E_xV5gLfWpa


Documentación oficial de Terraform  https://developer.hashicorp.com/terraform


Documentación oficial de AWS       https://signin.aws.amazon.com/

Sigueme en mis redes para mas contenido sobre ciberseguridad y cloud.

## Conclusion 
Este laboratorio permite: 
- Implementar infraestructura segura y automatizada en AWS.
- Aprender buenas practicas de IaC.
- Experimentar con roles diferenciados y acceso seguro a servicios criticos.
- Escalar y reproducir un SOC de manera eficiente y segura.


LABORATORIO REALIZADO POR AZUL ROCIO FERREYRA / ANZUR 12/11/2025
