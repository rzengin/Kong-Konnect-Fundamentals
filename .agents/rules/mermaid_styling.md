---
name: mermaid-styling
description: Reglas estrictas para el estilo visual de los diagramas Mermaid en la documentación.
---

# Estilo Estandarizado para Diagramas Mermaid

Cuando generes, actualices o modifiques un diagrama Mermaid en cualquier documento del proyecto, **DEBES** aplicar el siguiente estilo visual estandarizado. 

## 1. Inicialización del Tema
Todo diagrama Mermaid debe comenzar con la siguiente inicialización de tema oscuro para hacer match con la estética del portal y de Kong:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'darkMode': true, 'background': '#0f172a', 'primaryColor': '#1e293b', 'primaryTextColor': '#e2e8f0', 'lineColor': '#0ea5e9', 'fontFamily': 'sans-serif' }}}%%
flowchart TB
```

## 2. Definición de Clases (classDef)
Debes incluir las siguientes clases estándar justo después de la declaración del gráfico, y aplicarlas a los nodos y subgrafos correspondientes:

```mermaid
    classDef cp_style fill:#082f49,stroke:#0ea5e9,stroke-width:2px,color:#bae6fd,rx:10,ry:10;
    classDef dp_style fill:#431407,stroke:#f97316,stroke-width:2px,color:#fed7aa,rx:10,ry:10;
    classDef inner_cp fill:#0369a1,stroke:#38bdf8,stroke-width:1px,color:#f0f9ff;
    classDef inner_dp fill:#c2410c,stroke:#fdba74,stroke-width:1px,color:#fff7ed;
    classDef portal_style fill:#064e3b,stroke:#10b981,stroke-width:2px,color:#a7f3d0,rx:10,ry:10;
    classDef inner_portal fill:#047857,stroke:#34d399,stroke-width:1px,color:#ecfdf5;
    classDef client_style fill:#1e293b,stroke:#94a3b8,stroke-width:2px,color:#f8fafc,rx:20,ry:20;
```

## 3. Reglas de Asignación Semántica
- **Control Plane (Konnect, Productos Lógicos):** Usa `cp_style` para subgrafos y `:::inner_cp` para nodos internos.
- **Data Plane (Gateway, Mock Backends, Logs):** Usa `dp_style` para subgrafos y `:::inner_dp` para nodos internos.
- **Portal / Entorno Público:** Usa `portal_style` para subgrafos y `:::inner_portal` para nodos (Sitios web, Catálogos).
- **Clientes / Aplicaciones:** Usa `:::client_style` para actores externos (cURL, DevApp, etc).

## 4. Estilos de Líneas (linkStyle)
Asegúrate de estilizar las líneas con `linkStyle` para que coincidan visualmente con el área que conectan. 
- Usa colores celestes (`#0ea5e9`) para tráfico de Management/Control Plane.
- Usa colores naranjas (`#f97316`) para tráfico de Data Plane / HTTP Proxies.
- Usa colores esmeralda (`#10b981`) para integraciones del Portal.
- Usa `stroke-dasharray: 5 5` para sincronizaciones asíncronas o relaciones lógicas, y líneas continuas para tráfico real.
