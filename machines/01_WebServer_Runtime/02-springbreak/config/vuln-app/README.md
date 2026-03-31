# Spring4Shell Vulnerable Application

This directory contains a minimal Spring Boot WAR that is vulnerable to CVE-2022-22965.

## Build Instructions (for development)

The vulnerable WAR requires:
- Spring Framework 5.3.17 (before patch)
- JDK 9+ (class loader manipulation)
- Tomcat 9.x WAR deployment

The Dockerfile downloads and deploys the pre-built vulnerable WAR.

## Attack Vector

Class loader parameter manipulation via HTTP allows writing a JSP webshell:
```
GET /?class.module.classLoader.resources.context.parent.pipeline.first.pattern=PAYLOAD
```
