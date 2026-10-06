# Avaliação do curso

Parabéns por concluir o treinamento Kong API Gateway!

Sua opinião é essencial para nos ajudar a melhorar. Reserve um momento para preencher o formulário abaixo.

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

  <h3>1. Dados Pessoais</h3>
  <div class="form-group">
    <label>Nome completo *</label>
    <input type="text" name="nombre" required placeholder="Ex. João Silva">
  </div>
  <div class="form-group">
    <label>E-mail *</label>
    <input type="email" name="email" required placeholder="Ex. joao@exemplo.com">
  </div>
  <div class="form-group">
    <label>Função na empresa *</label>
    <input type="text" name="rol" required placeholder="Ex. Arquiteto de Software, DevOps, etc.">
  </div>

  <h3>2. Ambiente e configuração</h3>
  <div class="form-group">
    <label>Como você avaliaria o ambiente local e a configuração fornecida para o curso (Docker, decK, Kong)? *</label>
    <select name="eval_setup" required>
      <option value="" disabled selected>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </select>
  </div>

  <h3>3. Módulos Teóricos (Dia 1)</h3>
  <div class="form-group">
    <label>Qualidade geral do conteúdo teórico e das demonstrações do Dia 1 *</label>
    <select name="eval_dia1_general" required>
      <option value="" disabled selected>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </select>
  </div>
  <div class="form-group">
    <label>Quais módulos do Dia 1 você acha que proporcionaram mais valor?</label>
    <div class="checkbox-group">
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Arquitetura e Setup"> Arquitetura e Setup</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Kong Konnect Gateway"> Kong Konnect Gateway</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Kong Plugins"> Kong Plugins</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Developer Portal"> Developer Portal</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Operações de Gateway (IaC)"> Operações de Gateway (IaC)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Monitoramento e Logging"> Monitoramento e Logging</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Observabilidade Avançada"> Observabilidade Avançada</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Protegendo o tráfego de APIs"> Protegendo o tráfego de APIs</label>
    </div>
  </div>

  <h3>4. Laboratórios Práticos (Dia 2)</h3>
  <div class="form-group">
    <label>Qualidade geral dos laboratórios práticos (Hands-on) do Dia 2 *</label>
    <select name="eval_dia2_general" required>
      <option value="" disabled selected>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </select>
  </div>
  <div class="form-group">
    <label>Quais laboratórios do Dia 2 você gostou ou achou mais úteis?</label>
    <div class="checkbox-group">
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Roteamento Declarativo"> Roteamento Declarativo</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Upstreams e Health Checks"> Upstreams e Health Checks</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Catalog APIs e OAS"> Catalog APIs e OAS</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Transformações"> Transformações</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Roteamento Inteligente"> Roteamento Inteligente</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Observabilidad OTel"> Observabilidade (OTel, OpenObserve e Phoenix)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Zero Trust"> Segurança Zero Trust</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="OIDC ACL"> Autenticação (OIDC e ACL)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="OPA"> Autorização Avançada (OPA)</label>
    </div>
  </div>

  <h3>5. Módulos de AI Gateway (Dia 3)</h3>
  <div class="form-group">
    <label>Qualidade geral do conteúdo teórico e das demonstrações de AI Gateway do Dia 3</label>
    <select name="eval_dia3_general">
      <option value="" disabled selected>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </select>
  </div>
  <div class="form-group">
    <label>Quais módulos do Dia 3 você acha que proporcionaram mais valor?</label>
    <div class="checkbox-group">
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Arquitetura AI Gateway 2.x e kongctl"> Arquitetura AI Gateway 2.x e kongctl</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Um endpoint, muitos LLMs"> Um endpoint, muitos LLMs</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Governança, cotas e orçamento"> Governança, cotas e orçamento</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Guardrails e PII"> Guardrails e PII</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Roteamento semântico, cache e compressão"> Roteamento semântico, cache e compressão</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="RAG gerenciado"> RAG gerenciado</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="MCP (APIs como tools)"> MCP (APIs como tools)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Agentes e A2A"> Agentes e A2A</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Observabilidade e FinOps de IA"> Observabilidade e FinOps de IA</label>
      <label class="checkbox-label"><input type="checkbox" name="dia3_modulos[]" value="Novidades AI Summit 2026"> Novidades AI Summit 2026</label>
    </div>
  </div>

  <h3>6. Laboratórios de AI Gateway (Dia 4)</h3>
  <div class="form-group">
    <label>Qualidade geral dos laboratórios de AI Gateway do Dia 4</label>
    <select name="eval_dia4_general">
      <option value="" disabled selected>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </select>
  </div>
  <div class="form-group">
    <label>Quais laboratórios do Dia 4 você gostou ou achou mais úteis?</label>
    <div class="checkbox-group">
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Setup do AI Gateway"> Setup do AI Gateway</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Multi-LLM e Failover"> Multi-LLM e Failover</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Governança e Cotas"> Governança e Cotas</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Guardrails"> Guardrails</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Semântica e Cache"> Semântica e Cache</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="RAG"> RAG</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="MCP"> MCP</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="A2A"> A2A</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Observabilidade (OpenObserve & Phoenix)"> Observabilidade (OpenObserve & Phoenix)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia4_labs[]" value="Desafio: Assistente de Crédito"> Desafio: Assistente de Crédito</label>
    </div>
  </div>

  <h3>7. Avaliação do Instrutor</h3>
  <div class="form-group">
    <label>Clareza na exposição e facilidade para explicar conceitos complexos *</label>
    <select name="inst_claridad" required>
      <option value="" disabled selected>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </select>
  </div>
  <div class="form-group">
    <label>Domínio do assunto e experiência técnica *</label>
    <select name="inst_dominio" required>
      <option value="" disabled selected>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </select>
  </div>
  <div class="form-group">
    <label>Disponibilidade e capacidade para resolver dúvidas *</label>
    <select name="inst_dudas" required>
      <option value="" disabled selected>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </select>
  </div>
  <div class="form-group">
    <label>Gestão do tempo e ritmo da aula *</label>
    <select name="inst_tiempo" required>
      <option value="" disabled selected>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </select>
  </div>

  <h3>8. Comentários Finais</h3>
  <div class="form-group">
    <label>O que poderíamos melhorar para a próxima edição? (Opcional)</label>
    <textarea name="comentarios_finales" rows="4" placeholder="Escreva aqui qualquer sugestão..."></textarea>
  </div>

  <button type="submit">Enviar Avaliação</button>
</form>
