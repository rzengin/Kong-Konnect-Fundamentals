# Evaluación del Curso

¡Felicidades por haber completado el entrenamiento de Kong API Gateway!

Tu opinión es fundamental para ayudarnos a mejorar. Por favor, tómate un momento para completar el siguiente formulario.

<style>
.eval-form {
  max-width: 800px;
  background: #ffffff;
  padding: 2rem;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
  margin-top: 2rem;
}
.eval-form h3 { 
  margin-top: 2rem; 
  margin-bottom: 1rem; 
  border-bottom: 2px solid #f0f0f0; 
  padding-bottom: 0.5rem; 
  color: #333;
}
.eval-form h3:first-child { margin-top: 0; }
.eval-form .form-group { margin-bottom: 1.5rem; }
.eval-form label { 
  display: block; 
  font-weight: 600; 
  margin-bottom: 0.5rem; 
  color: #444;
}
.eval-form input[type="text"], 
.eval-form input[type="email"], 
.eval-form select, 
.eval-form textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-family: inherit;
  font-size: 1rem;
}
.eval-form input:focus, .eval-form select:focus, .eval-form textarea:focus {
  outline: none;
  border-color: #03a87c;
  box-shadow: 0 0 0 2px rgba(3, 168, 124, 0.2);
}
.eval-form .checkbox-group { 
  display: grid; 
  grid-template-columns: 1fr 1fr; 
  gap: 0.75rem; 
}
.eval-form .checkbox-label { 
  font-weight: normal; 
  display: flex; 
  align-items: flex-start; 
  cursor: pointer;
}
.eval-form .checkbox-label input { 
  margin-right: 0.5rem; 
  margin-top: 0.2rem;
}
.eval-form button {
  background: #03a87c; 
  color: white;
  padding: 1rem 2rem;
  border: none;
  border-radius: 4px;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
  margin-top: 1rem;
  width: 100%;
  transition: background 0.2s;
}
.eval-form button:hover { background: #028a65; }
</style>

<form action="https://formspree.io/f/maeybbjl" method="POST" class="eval-form">

  <h3>1. Datos Personales</h3>
  <div class="form-group">
    <label>Nombre Completo *</label>
    <input type="text" name="nombre" required placeholder="Ej. Juan Pérez">
  </div>
  <div class="form-group">
    <label>Correo Electrónico *</label>
    <input type="email" name="email" required placeholder="Ej. juan@ejemplo.com">
  </div>
  <div class="form-group">
    <label>Rol en la empresa *</label>
    <input type="text" name="rol" required placeholder="Ej. Arquitecto de Software, DevOps, etc.">
  </div>

  <h3>2. Entorno y Setup</h3>
  <div class="form-group">
    <label>¿Cómo calificarías el entorno local y setup provisto para el curso (Docker, decK, Kong)? *</label>
    <select name="eval_setup" required>
      <option value="" disabled selected>Selecciona una opción...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bueno">Bueno</option>
      <option value="Regular">Regular</option>
      <option value="Malo">Malo</option>
      <option value="No opino">No opino / No aplica</option>
    </select>
  </div>

  <h3>3. Módulos Teóricos (Día 1)</h3>
  <div class="form-group">
    <label>Calidad general del contenido teórico y demostraciones del Día 1 *</label>
    <select name="eval_dia1_general" required>
      <option value="" disabled selected>Selecciona una opción...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bueno">Bueno</option>
      <option value="Regular">Regular</option>
      <option value="Malo">Malo</option>
      <option value="No opino">No opino / No aplica</option>
    </select>
  </div>
  <div class="form-group">
    <label>¿Cuáles módulos del Día 1 consideras que aportaron más valor?</label>
    <div class="checkbox-group">
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Arquitectura y Setup"> Arquitectura y Setup</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Kong Konnect Gateway"> Kong Konnect Gateway</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Kong Plugins"> Kong Plugins</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Developer Portal"> Developer Portal</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Gateway Operations (IaC)"> Gateway Operations (IaC)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Monitoring & Logging"> Monitoring & Logging</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Observabilidad Avanzada"> Observabilidad Avanzada</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Securing API Traffic"> Securing API Traffic</label>
    </div>
  </div>

  <h3>4. Laboratorios Prácticos (Día 2)</h3>
  <div class="form-group">
    <label>Calidad general de los laboratorios prácticos (Hands-on) del Día 2 *</label>
    <select name="eval_dia2_general" required>
      <option value="" disabled selected>Selecciona una opción...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bueno">Bueno</option>
      <option value="Regular">Regular</option>
      <option value="Malo">Malo</option>
      <option value="No opino">No opino / No aplica</option>
    </select>
  </div>
  <div class="form-group">
    <label>¿Cuáles laboratorios del Día 2 disfrutaste o te sirvieron más?</label>
    <div class="checkbox-group">
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Routing Declarativo"> Routing Declarativo</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Upstreams & Health Checks"> Upstreams & Health Checks</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Catalog APIs & OAS"> Catalog APIs & OAS</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Transformaciones"> Transformaciones</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Ruteo Inteligente"> Ruteo Inteligente</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Observabilidad OTel"> Observabilidad (OTel, OpenObserve & Phoenix)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Zero Trust"> Seguridad Zero Trust</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="OIDC ACL"> Autenticación (OIDC & ACL)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="OPA"> Autorización Avanzada (OPA)</label>
    </div>
  </div>

  <h3>5. Evaluación del Instructor</h3>
  <div class="form-group">
    <label>Claridad en la exposición y facilidad para explicar conceptos complejos *</label>
    <select name="inst_claridad" required>
      <option value="" disabled selected>Selecciona una opción...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bueno">Bueno</option>
      <option value="Regular">Regular</option>
      <option value="Malo">Malo</option>
      <option value="No opino">No opino / No aplica</option>
    </select>
  </div>
  <div class="form-group">
    <label>Dominio del tema y experiencia técnica *</label>
    <select name="inst_dominio" required>
      <option value="" disabled selected>Selecciona una opción...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bueno">Bueno</option>
      <option value="Regular">Regular</option>
      <option value="Malo">Malo</option>
      <option value="No opino">No opino / No aplica</option>
    </select>
  </div>
  <div class="form-group">
    <label>Disposición y capacidad para resolver dudas *</label>
    <select name="inst_dudas" required>
      <option value="" disabled selected>Selecciona una opción...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bueno">Bueno</option>
      <option value="Regular">Regular</option>
      <option value="Malo">Malo</option>
      <option value="No opino">No opino / No aplica</option>
    </select>
  </div>
  <div class="form-group">
    <label>Manejo del tiempo y ritmo de la clase *</label>
    <select name="inst_tiempo" required>
      <option value="" disabled selected>Selecciona una opción...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bueno">Bueno</option>
      <option value="Regular">Regular</option>
      <option value="Malo">Malo</option>
      <option value="No opino">No opino / No aplica</option>
    </select>
  </div>

  <h3>6. Comentarios Finales</h3>
  <div class="form-group">
    <label>¿Qué podríamos mejorar para la próxima edición? (Opcional)</label>
    <textarea name="comentarios_finales" rows="4" placeholder="Escribe aquí cualquier sugerencia..."></textarea>
  </div>

  <button type="submit">Enviar Evaluación</button>
</form>
