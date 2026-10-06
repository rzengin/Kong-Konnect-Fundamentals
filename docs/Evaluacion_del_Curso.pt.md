# Avaliação do curso

Parabéns por concluir o treinamento Kong API Gateway!

Sua opinião é essencial para nos ajudar a melhorar. Reserve um momento para preencher o formulário abaixo.

<estilo>
.eval-form {
  largura máxima: 800px;
  plano de fundo: #ffffff;
  preenchimento: 2rem;
  raio da borda: 8px;
  borda: 1px sólido #e0e0e0;
  sombra da caixa: 0 4px 6px rgba (0,0,0,0,05);
  margem superior: 2rem;
}
.eval-form h3 { 
  margem superior: 2rem; 
  margem inferior: 1rem; 
  borda inferior: 2px sólido #f0f0f0; 
  fundo de preenchimento: 0,5rem; 
  cor: #333;
}
.eval-form h3:primeiro-filho {margem superior: 0; }
.eval-form .form-group {margem inferior: 1,5rem; }
rótulo .eval-form { 
  exibição: bloco; 
  peso da fonte: 600; 
  margem inferior: 0,5rem; 
  cor: #444;
}
.eval-form input[type="text"], 
.eval-form input[type="email"], 
.eval-form selecione, 
área de texto .eval-form {
  largura: 100%;
  preenchimento: 0,75rem;
  borda: 1px sólido #ccc;
  raio da borda: 4px;
  família de fontes: herdar;
  tamanho da fonte: 1rem;
}
.eval-form input:focus, .eval-form select:focus, .eval-form textarea:focus {
  esboço: nenhum;
  cor da borda: #03a87c;
  sombra da caixa: 0 0 0 2px rgba(3, 168, 124, 0,2);
}
.eval-form .checkbox-grupo { 
  exibição: grade; 
  colunas de modelo de grade: 1fr 1fr; 
  lacuna: 0,75rem; 
}
.eval-form .checkbox-label { 
  peso da fonte: normal; 
  exibição: flexível; 
  alinhar itens: flex-start; 
  cursor: ponteiro;
}
.eval-form .checkbox-label entrada { 
  margem direita: 0,5rem; 
  margem superior: 0,2rem;
}
botão .eval-form {
  plano de fundo: #03a87c; 
  cor: branco;
  preenchimento: 1rem 2rem;
  fronteira:nenhuma;
  raio da borda: 4px;
  tamanho da fonte: 1,1rem;
  peso da fonte: negrito;
  cursor: ponteiro;
  margem superior: 1rem;
  largura: 100%;
  transição: fundo 0,2s;
}
Botão .eval-form:hover { background: #028a65; }
</estilo>

<form action="https://formspree.io/f/maeybbjl" method="POST" class="eval-form">

  <h3>1. Dados Pessoais</h3>
  <div class="form-group">
    <label>Nome completo*</label>
    <input type="text" name="name" obrigatório placeholder="Ex. Juan Pérez">
  </div>
  <div class="form-group">
    <label>E-mail *</label>
    <input type="email" name="email" obrigatório placeholder="Ex. john@example.com">
  </div>
  <div class="form-group">
    <label>Função na empresa *</label>
    <input type="text" name="role" require placeholder="Ex. Arquiteto de Software, DevOps, etc.">
  </div>

  <h3>2. Ambiente e configuração</h3>
  <div class="form-group">
    <label>Como você avaliaria o ambiente local e a configuração fornecida para o curso (Docker, deck, Kong)? *</label>
    <selecionar nome="eval_setup" obrigatório>
      <option value="" desativado selecionado>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </selecionar>
  </div>

  <h3>3. Módulos Teóricos (Dia 1)</h3>
  <div class="form-group">
    <label>Qualidade geral do conteúdo teórico e demonstrações do Dia 1*</label>
    <selecionar nome="eval_day1_general" obrigatório>
      <option value="" desativado selecionado>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </selecionar>
  </div>
  <div class="form-group">
    <label>Quais módulos do primeiro dia você acha que proporcionaram mais valor?</label>
    <div class="checkbox-grupo">
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Arquitetura e configuração"> Arquitetura e configuração</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Kong Konnect Gateway"> Kong Konnect Gateway</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Plugins Kong"> Plugins Kong</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Portal do Desenvolvedor"> Portal do Desenvolvedor</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Operações de gateway (IaC)"> Operações de gateway (IaC)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Monitoring & Logging"> Monitoramento e Logging</label>
<label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Observabilidade Avançada"> Observabilidade Avançada</label>
      <label class="checkbox-label"><input type="checkbox" name="dia1_modulos[]" value="Protegendo o tráfego da API"> Protegendo o tráfego da API</label>
    </div>
  </div>

  <h3>4. Laboratórios Práticos (Dia 2)</h3>
  <div class="form-group">
    <label>Qualidade geral dos laboratórios práticos (Hands-on) do Dia 2 *</label>
    <select name="eval_day2_general" obrigatório>
      <option value="" desativado selecionado>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </selecionar>
  </div>
  <div class="form-group">
    <label>Quais laboratórios do dia 2 você gostou ou achou mais úteis?</label>
    <div class="checkbox-grupo">
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Roteamento Declarativo"> Roteamento Declarativo</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Upstreams e verificações de integridade"> Upstreams e verificações de integridade</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="APIs de catálogo e OAS"> APIs de catálogo e OAS</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Transformations"> Transformações</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Roteamento inteligente"> Roteamento inteligente</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="OTel Observability"> Observabilidade (OTel, OpenObserve e Phoenix)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="Zero Trust"> Segurança Zero Trust</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="OIDC ACL"> Autenticação (OIDC e ACL)</label>
      <label class="checkbox-label"><input type="checkbox" name="dia2_labs[]" value="OPA"> Autorização Avançada (OPA)</label>
    </div>
  </div>

  <h3>5. Avaliação do instrutor</h3>
  <div class="form-group">
    <label>Clareza na apresentação e facilidade na explicação de conceitos complexos *</label>
    <select name="inst_clarity" obrigatório>
      <option value="" desativado selecionado>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </selecionar>
  </div>
  <div class="form-group">
    <label>Domínio do assunto e experiência técnica *</label>
    <select name="inst_domain" obrigatório>
      <option value="" desativado selecionado>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </selecionar>
  </div>
  <div class="form-group">
    <label>Disponibilidade e capacidade para resolver dúvidas *</label>
    <select name="inst_doubts" obrigatório>
      <option value="" desativado selecionado>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </selecionar>
  </div>
  <div class="form-group">
    <label>Gerenciamento de tempo e ritmo de aula *</label>
    <select name="inst_time" obrigatório>
      <option value="" desativado selecionado>Selecione uma opção...</option>
      <option value="Excelente">Excelente</option>
      <option value="Bom">Bom</option>
      <option value="Regular">Regular</option>
      <option value="Ruim">Ruim</option>
      <option value="Não tenho opinião">Não tenho opinião / Não aplicável</option>
    </selecionar>
  </div>

  <h3>6. Comentários finais</h3>
  <div class="form-group">
    <label>O que podemos melhorar para a próxima edição? (Opcional)</label>
    <textarea name="final_comments" rows="4" placeholder="Escreva alguma sugestão aqui..."></textarea>
  </div>

  <button type="submit">Enviar avaliação</button>
</form>
