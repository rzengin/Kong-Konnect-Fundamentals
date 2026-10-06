# Course Evaluation

Congratulations on completing the Kong API Gateway training!

Your feedback is essential to help us improve. Please take a moment to complete the following form.

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

  <h3>1. Personal Information</h3>
  <div class="form-group">
    <label>Full Name *</label>
    <input type="text" name="nombre" required placeholder="E.g. John Doe">
  </div>
  <div class="form-group">
    <label>Email Address *</label>
    <input type="email" name="email" required placeholder="E.g. john@example.com">
  </div>
  <div class="form-group">
    <label>Role in the company *</label>
    <input type="text" name="rol" required placeholder="E.g. Software Architect, DevOps, etc.">
  </div>

  <h3>2. Environment and Setup</h3>
  <div class="form-group">
    <label>How would you rate the local environment and setup provided for the course (Docker, decK, Kong)? *</label>
    <select name="eval_setup" required>
      <option value="" disabled selected>Select an option...</option>
      <option value="Excellent">Excellent</option>
      <option value="Good">Good</option>
      <option value="Fair">Fair</option>
      <option value="Poor">Poor</option>
      <option value="No opinion">No opinion / Not applicable</option>
    </select>
  </div>

  <h3>3. Theoretical Modules (Day 1)</h3>
  <div class="form-group">
    <label>Overall quality of theoretical content and demonstrations on Day 1 *</label>
    <select name="eval_dia1_general" required>
      <option value="" disabled selected>Select an option...</option>
      <option value="Excellent">Excellent</option>
      <option value="Good">Good</option>
      <option value="Fair">Fair</option>
      <option value="Poor">Poor</option>
      <option value="No opinion">No opinion / Not applicable</option>
    </select>
  </div>
  <div class="form-group">
    <label>Which Day 1 modules do you consider to have provided the most value?</label>
    <div class="checkbox-group">
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Architecture and Setup"> Architecture and Setup</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Kong Konnect Gateway"> Kong Konnect Gateway</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Kong Plugins"> Kong Plugins</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Developer Portal"> Developer Portal</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Gateway Operations (IaC)"> Gateway Operations (IaC)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Monitoring & Logging"> Monitoring & Logging</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Advanced Observability"> Advanced Observability</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Securing API Traffic"> Securing API Traffic</label>
    </div>
  </div>

  <h3>4. Practical Labs (Day 2)</h3>
  <div class="form-group">
    <label>Overall quality of practical labs (Hands-on) on Day 2 *</label>
    <select name="eval_dia2_general" required>
      <option value="" disabled selected>Select an option...</option>
      <option value="Excellent">Excellent</option>
      <option value="Good">Good</option>
      <option value="Fair">Fair</option>
      <option value="Poor">Poor</option>
      <option value="No opinion">No opinion / Not applicable</option>
    </select>
  </div>
  <div class="form-group">
    <label>Which Day 2 labs did you enjoy or find most useful?</label>
    <div class="checkbox-group">
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Declarative Routing"> Declarative Routing</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Upstreams & Health Checks"> Upstreams & Health Checks</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Catalog APIs & OAS"> Catalog APIs & OAS</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Transformations"> Transformations</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Intelligent Routing"> Intelligent Routing</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Observability OTel"> Observability (OTel, OpenObserve & Phoenix)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Zero Trust Security"> Zero Trust Security</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="OIDC ACL"> Authentication (OIDC & ACL)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="OPA"> Advanced Authorization (OPA)</label>
    </div>
  </div>

  <h3>5. AI Gateway Modules (Day 3)</h3>
  <div class="form-group">
    <label>Overall quality of the Day 3 AI Gateway theory content and demos</label>
    <select name="eval_dia3_general">
      <option value="" disabled selected>Select an option...</option>
      <option value="Excellent">Excellent</option>
      <option value="Good">Good</option>
      <option value="Fair">Fair</option>
      <option value="Poor">Poor</option>
      <option value="No opinion">No opinion / Not applicable</option>
    </select>
  </div>
  <div class="form-group">
    <label>Which Day 3 modules do you think provided the most value?</label>
    <div class="checkbox-group">
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="AI Gateway 2.x Architecture and kongctl"> AI Gateway 2.x Architecture and kongctl</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="One endpoint, many LLMs"> One endpoint, many LLMs</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Governance, quotas and budget"> Governance, quotas and budget</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Guardrails and PII"> Guardrails and PII</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Semantic routing, caching and compression"> Semantic routing, caching and compression</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Managed RAG"> Managed RAG</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="MCP (APIs as tools)"> MCP (APIs as tools)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Agents and A2A"> Agents and A2A</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="AI Observability and FinOps"> AI Observability and FinOps</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="AI Summit 2026 Announcements"> AI Summit 2026 Announcements</label>
    </div>
  </div>

  <h3>6. AI Gateway Labs (Day 4)</h3>
  <div class="form-group">
    <label>Overall quality of the Day 4 AI Gateway labs</label>
    <select name="eval_dia4_general">
      <option value="" disabled selected>Select an option...</option>
      <option value="Excellent">Excellent</option>
      <option value="Good">Good</option>
      <option value="Fair">Fair</option>
      <option value="Poor">Poor</option>
      <option value="No opinion">No opinion / Not applicable</option>
    </select>
  </div>
  <div class="form-group">
    <label>Which Day 4 labs did you enjoy or find most useful?</label>
    <div class="checkbox-group">
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="AI Gateway Setup"> AI Gateway Setup</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Multi-LLM and Failover"> Multi-LLM and Failover</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Governance and Quotas"> Governance and Quotas</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Guardrails"> Guardrails</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Semantics and Caching"> Semantics and Caching</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="RAG"> RAG</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="MCP"> MCP</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="A2A"> A2A</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Observability (OpenObserve & Phoenix)"> Observability (OpenObserve & Phoenix)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Challenge: Governed Credit Assistant"> Challenge: Governed Credit Assistant</label>
    </div>
  </div>

  <h3>7. Instructor Evaluation</h3>
  <div class="form-group">
    <label>Clarity in presentation and ease of explaining complex concepts *</label>
    <select name="inst_claridad" required>
      <option value="" disabled selected>Select an option...</option>
      <option value="Excellent">Excellent</option>
      <option value="Good">Good</option>
      <option value="Fair">Fair</option>
      <option value="Poor">Poor</option>
      <option value="No opinion">No opinion / Not applicable</option>
    </select>
  </div>
  <div class="form-group">
    <label>Subject matter expertise and technical experience *</label>
    <select name="inst_dominio" required>
      <option value="" disabled selected>Select an option...</option>
      <option value="Excellent">Excellent</option>
      <option value="Good">Good</option>
      <option value="Fair">Fair</option>
      <option value="Poor">Poor</option>
      <option value="No opinion">No opinion / Not applicable</option>
    </select>
  </div>
  <div class="form-group">
    <label>Willingness and ability to answer questions *</label>
    <select name="inst_dudas" required>
      <option value="" disabled selected>Select an option...</option>
      <option value="Excellent">Excellent</option>
      <option value="Good">Good</option>
      <option value="Fair">Fair</option>
      <option value="Poor">Poor</option>
      <option value="No opinion">No opinion / Not applicable</option>
    </select>
  </div>
  <div class="form-group">
    <label>Time management and class pace *</label>
    <select name="inst_tiempo" required>
      <option value="" disabled selected>Select an option...</option>
      <option value="Excellent">Excellent</option>
      <option value="Good">Good</option>
      <option value="Fair">Fair</option>
      <option value="Poor">Poor</option>
      <option value="No opinion">No opinion / Not applicable</option>
    </select>
  </div>

  <h3>8. Final Comments</h3>
  <div class="form-group">
    <label>What could we improve for the next edition? (Optional)</label>
    <textarea name="comentarios_finales" rows="4" placeholder="Write any suggestions here..."></textarea>
  </div>

  <button type="submit">Submit Evaluation</button>
</form>