-- LUNAR COURIER - textos da historia, PORTUGUES (ASCII puro: o runtime AKA-Love nao desenha acentos).
-- Uma entrada por missao, mesma ordem de data.lua. Limites (fonte AKA pior caso : 1 caractere = 16 px) :
--   nome <= 20, objetivo <= 26, titulo de cartao <= 21, corpo : 31 caracteres por linha, 12 linhas, radio <= 66.
-- Dialogos : um paragrafo comeca por "LUNA :", "VARGA :" ou "CONTROLE :" (cor e retrato automaticos).
return {
-- M1
 {name="PRIMEIRA LUZ", objective="Reacenda o farol Alfa",
  pre={
   {"DIARIO DE MISSAO 01", "A colonia lunar parou de responder. Voce e o ultimo piloto disponivel. Um farol de emergencia ainda pisca alem das crateras. Entregue o modulo de energia e descubra quem mantem a rede viva."},
   {"BRIEFING", "LUNA : Sistemas ativos, piloto. Sou LUNA, sua assistente de bordo. A gravidade e baixa: acelere, gire e pouse com suavidade.\n\nLUNA : Primeiro alvo, o farol Alfa. Pegue a capsula laranja e mire o marcador ciano."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "O farol Alfa acabou de responder. O sinal e fraco, mas nao e natural: alguem manteve a rede funcionando desde a evacuacao.\n\nLUNA : Alguem ainda vigia. Vamos encontra-lo."},
  },
  radio={"LUNA : Pegue a capsula laranja e depois mire o marcador ciano."}},
-- M2
 {name="ECOS DA CRATERA", objective="Recupere o retransmissor",
  pre={
   {"BRIEFING", "LUNA : Alfa responde, mas o resto da rede esta mudo. O retransmissor da cratera deve guardar os registros da evacuacao.\n\nLUNA : Cuidado, uma rocha bloqueia a trilha. Desvie: o casco odeia surpresas."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "O retransmissor guarda uma mensagem de onze anos atras. Uma voz ainda pede socorro da estacao Argo.\n\nLUNA : Argo... Esse nome me parece familiar. Nao sei por que."},
  },
  radio={"LUNA : Deslizamento de rochas na trilha. Contorne, piloto."}},
-- M3
 {name="ESTACAO FANTASMA", objective="Restaure a energia",
  pre={
   {"BRIEFING", "LUNA : A estacao Argo aparece em nossas cartas: sem tripulacao, sem luzes. Mas seus paineis solares estao limpos. Alguem os limpa.\n\nLUNA : A energia de reserva esta falhando. Vamos reacende-la juntos."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "LUNA confirma que a estacao nao esta vazia. Os sistemas despertam quando voce se aproxima.\n\nLUNA : As janelas se acendem uma a uma. Parece que ela nos esperava."},
  },
  radio={"LUNA : A estacao desperta conforme nos aproximamos."}},
-- M4
 {name="A FENDA AZUL", objective="Atravesse o canyon",
  pre={
   {"BRIEFING", "LUNA : Os registros falam de um reator enterrado sob a Fenda Azul. Um canyon nos separa do proximo farol.\n\nLUNA : Nao peco que desca la, piloto. Sobrevoar basta."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "Os dados revelam uma rede de farois feita para guiar naves ate um antigo reator enterrado sob a crosta lunar.\n\nLUNA : Um reator, farois como migalhas de pao... Alguem planejou tudo."},
  },
  radio={"LUNA : O canyon so morde quem demora."}},
-- M5
 {name="O CORACAO MUDO", objective="Entregue o modulo",
  pre={
   {"BRIEFING", "LUNA : A rede converge para o Coracao. O modulo que voce leva deve ser entregue la: seu codigo e o unico que abre a eclusa.\n\nLUNA : O farol esta num planalto. Suba e pouse bem nivelado."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "A eclusa aceita o modulo, mas o reator continua mudo. As plantas indicam um encaixe central e um console de comando.\n\nLUNA : O codigo me e familiar. Mas a fase de partida... nao entendo por que."},
  },
  radio={}},
-- M6
 {name="REDE DE LUZ", objective="Ative o ultimo farol",
  pre={
   {"BRIEFING", "LUNA : Este e o ultimo farol da rede conhecida. Se ele acender, toda a colonia podera nos ouvir de novo.\n\nLUNA : Aconteca o que acontecer la fora, piloto... obrigada por ser o ultimo piloto disponivel."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "Todos os farois se acendem. A colonia finalmente responde. A voz da estacao Argo nao era um pedido de socorro, mas uma mensagem deixada ao proximo piloto."},
   {"UMA LUA DESPERTA", "Os farois agora brilham de cratera em cratera. A colonia voltou a falar com a Terra.\n\nLUNA : Arquivando sua ultima entrega... Nenhum piloto deveria voltar. Voce e a excecao, Courier."},
   {"FIM DO CAPITULO 1", "A rede lunar esta ativa de novo. Mas uma nova rota acabou de acender, alem do lado conhecido da Lua, e ela nao esta em nenhuma carta.\n\nA mensagem de Argo dizia para segui-la."},
  },
  radio={"LUNA : Ultimo farol. Pouse nivelado, piloto."}},
-- M7
 {name="ALEM DO HORIZONTE", objective="Acorde o farol Beta",
  pre={
   {"O LADO OCULTO", "CAPITULO 2\n\nA estrada de luz segue para o lado que a Terra nunca ve. La fora nao ha ligacao com a Terra. So os farois e a voz de LUNA, a bordo."},
   {"BRIEFING", "LUNA : Em poucos minutos a Terra afundara no horizonte. Quando sumir, perco o contato com o Controle. Nao com voce: vivo nesta nave, piloto.\n\nLUNA : Calma: o farol Beta sera nosso proximo farol-guia. Pegue a capsula e pouse."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "Beta responde com uma assinatura: I. VARGA, comandante da estacao Argo. Entao a voz da mensagem nao era uma IA. Alguem construiu esta rede sabendo que outro piloto viria.\n\nLUNA : Ines Varga... O nome esta nos meus arquivos."},
  },
  radio={"LUNA : Terra abaixo do horizonte. Contato com a Terra perdido."}},
-- M8
 {name="SILENCIO DE RADIO", objective="Retransmita o sinal",
  pre={
   {"BRIEFING", "LUNA : Sem voz da Terra: so falo com voce de dentro da nave. Minhas leituras de velocidade ficarao instaveis as vezes, piloto: confie nos seus olhos.\n\nLUNA : Um vento de poeira sopra do norte. Ele empurra a nave: compense inclinando."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "Sem contato com a Terra, LUNA capta, pelos farois, uma gravacao de Varga: 'Aqui as ondas de radio nao viajam. Entao construi uma estrada de luz.'\n\nLUNA : Os farois sao as palavras dela, acesas uma a uma. Ela escreveu isso para alguem que nunca conheceu. Para voce."},
  },
  radio={"LUNA : Leituras confusas. Confie nos seus olhos.", "LUNA : O vento cai as vezes. Aproveite as calmarias."}},
-- M9
 {name="TRIANGULO DE LUZ", objective="Acenda os 3 farois",
  pre={
   {"BRIEFING", "LUNA : Tres farois, tres planaltos. Eles acordam se voce pousar em cada um, em sequencia.\n\nLUNA : Cada farol recarrega um pouco suas celulas. Varga pensou em tudo."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "Os tres farois formam uma seta. Ela aponta para a cratera Dedalo, onde a estacao Argo-2 foi selada ha onze anos. A mensagem de Varga termina com: 'Traga-me energia.'\n\nLUNA : Dedalo. Minhas cartas a apagam, como se alguem quisesse esquece-la."},
  },
  radio={"LUNA : Cada farol aceso recarrega um pouco as celulas."}},
-- M10
 {name="CAMPO DE DESTROCOS", objective="Atravesse os destrocos",
  pre={
   {"BRIEFING", "LUNA : O campo de destrocos esta a frente. Sao as naves da evacuacao, abandonadas em orbita baixa e caidas de volta.\n\nLUNA : Elas ainda derivam. Evite suas trajetorias, piloto, ou o casco paga."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "Estes destrocos sao as naves da evacuacao. Todas as cabines vazias. Num diario de bordo: 'Varga se recusou a embarcar. Ela fica para manter a estrada acesa.'\n\nLUNA : Onze anos mantendo a luz, sozinha. Entendo melhor o que e vigiar."},
  },
  radio={"LUNA : Os destrocos derivam. Observe suas trajetorias."}},
-- M11
 {name="ARGO DOIS", objective="Alcance Argo-2",
  pre={
   {"BRIEFING", "LUNA : Argo-2 a vista. A plataforma alta e acoitada por vento de frente. A capsula de Varga esta la, sob a cupula.\n\nLUNA : Detecto um batimento. Apenas um a cada noventa segundos. E ela."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "Argo-2 responde. A capsula de estase de Varga ainda resiste, com 3% de energia. Falta um ultimo modulo, a ser colocado na plataforma alta da estacao.\n\nLUNA : Precisamos de mais um modulo, e rapido. A ultima entrega, piloto."},
  },
  radio={"VARGA : (muito fraca) ...Courier? Eu te ouco... um pouco."}},
-- M12
 {name="A ENTREGA FINAL", objective="Entregue em Argo-2",
  pre={
   {"BRIEFING", "LUNA : Ultimo modulo do capitulo. A capsula esta em 3%. Se cair a zero... Nao. Nao vou terminar essa frase.\n\nLUNA : Vento forte, destrocos, plataforma alta. Voce consegue. Sempre conseguiu."},
  },
  post={
   {"TRANSMISSAO RECEBIDA", "Argo-2 se acende de uma so vez. Os farois do lado oculto se juntam a rede: pela primeira vez, a Lua inteira brilha na noite."},
   {"A CAPSULA SE ABRE", "A capsula se abre num sopro de geada. A comandante Ines Varga abre os olhos.\n\nVARGA : Onze anos... Voce demorou, Courier.\n\nDepois, mais suave, ela acrescenta:\n\nVARGA : Resta um ultimo pacote a entregar."},
   {"FIM DO CAPITULO 2", "A rede esta completa, do lado visivel ao lado oculto. Na plataforma de Argo-2, duas silhuetas veem a estrada de luz se estender ao norte, rumo a uma montanha que ninguem jamais deixou de mirar."},
  },
  radio={"VARGA : (voz falha) So mais alguns minutos. Aguente."}},
-- M13
 {name="REABASTECIMENTO", objective="Carregue as celulas",
  pre={
   {"O FAROL", "CAPITULO 3\n\nArgo-2, tres dias depois. A capsula libertou sua ocupante, fraca mas viva. O reator zumbe de novo. La fora, no lado oculto, os farois piscam as dezenas."},
   {"VARGA CONTA", "VARGA : O Coracao falhou no dia da evacuacao. Eu devia ficar uma semana, so o tempo de cortar os circuitos.\n\nVARGA : Depois entendi que a colonia nao morreria se alguem mantivesse uma luz acesa."},
   {"VARGA CONTA", "VARGA : Eu acordava uma semana por ano para consertar os farois com as Vagalumes, meus drones. No resto do tempo, dormia.\n\nLUNA : E eu velava sua capsula.\n\nVARGA : Sim. Como sempre."},
   {"O ULTIMO PACOTE", "VARGA : O Farol permanece. No topo do Monte Helios, onde o sol nunca se poe, uma antena espera seu coracao. Quando acender, a Terra nao precisara mais adivinhar que estamos vivos.\n\nVARGA : Digo o que e esse coracao quando chegar a hora."},
   {"BRIEFING", "VARGA : Primeiro passo: carregue as celulas da nave no deposito da plataforma. O Farol precisa de enorme energia para acender.\n\nVARGA : Eu fico aqui. Minhas pernas ainda nao me perdoaram pela capsula."},
  },
  post={
   {"DIARIO DE BORDO", "As celulas estao cheias. Na tela de navegacao, um traco branco sobe ao norte: a rota do Monte Helios, seis etapas, varias em plena temporada de tempestades solares.\n\nVARGA : Sem pressa, Courier. O Farol esperou onze anos por mim, pode esperar uma semana."},
  },
  radio={"VARGA : Calma, Courier. As celulas estao carregando."}},
-- M14
 {name="TEMPESTADE SOLAR", objective="Atravesse a tempestade",
  pre={
   {"BRIEFING", "VARGA : A temporada de tempestades solares comecou. Raios varrem a superficie a intervalos: um toque e seu casco derrete.\n\nLUNA : Detecto um padrao. Cada raio avisa antes de atacar: uma linha piscando. Aprenda esse ritmo."},
  },
  post={
   {"DIARIO DE BORDO", "Voce atravessou a tempestade. Ao longe, o primeiro retransmissor do norte se acende: a estrada esta aberta.\n\nLUNA : Piloto... atravessando esses raios, tive um sonho. Ou o mais proximo disso numa IA. Uma montanha muito alta e uma luz me chamando."},
  },
  radio={"LUNA : Raio em 3, 2... Espere a linha piscar."}},
-- M15
 {name="OS VAGALUMES", objective="Siga os Vagalumes",
  pre={
   {"BRIEFING", "VARGA : Os Vagalumes esperam por voce no proximo planalto. Meus pequenos drones ficaram muito tempo sem dono. Vao receber voce bem.\n\nVARGA : Nao bata neles: sao frageis e teimosos."},
  },
  post={
   {"DIARIO DE BORDO", "Os Vagalumes guiam a nave de farol em farol.\n\nVARGA : Eles te reconhecem, minha velha.\n\nLUNA : Eles me chamam por outro nome.\n\nVARGA : Explico no cume."},
  },
  radio={"LUNA : Os Vagalumes me chamam. Nao conheco o nome deles."}},
-- M16
 {name="DESFILADEIRO", objective="Atravesse o desfiladeiro",
  pre={
   {"REDE ATIVA", "Os Vagalumes sincronizaram os farois. O repetidor Argo envia enfim um pulso para a Terra. Uma janela de transmissao abriu.\n\nLUNA : A rede voltou a funcionar. Alguem responde."},
   {"CENTRO LAGRANGE", "CONTROLE : ...aqui Centro Lagrange, respondam... Piloto, recebemos seus farois desde esta manha. Achavamos a Lua perdida. Quem e voce?\n\nLUNA : Aqui o Courier, nave de entregas lunar. Estamos acendendo a estrada."},
   {"CENTRO LAGRANGE", "CONTROLE : Aqui Theo Marchand, controlador. Seus farois piscam em codigo ha onze anos. Uma palavra, repetida. Demoramos a le-la.\n\nCONTROLE : VIVOS. Dizia: VIVOS."},
   {"BRIEFING", "LUNA : Desfiladeiro das Sombras. Os raios ricocheteiam nas paredes: tres clarroes, tres ritmos.\n\nLUNA : Passe entre os clarroes, piloto. Um toque e voce perde casco, nao a calma."},
  },
  post={
   {"CENTRO LAGRANGE", "CONTROLE : A Terra inteira esta ouvindo, Courier. Avisamos as familias dos evacuados. Elas olham a Lua esta noite.\n\nVARGA : Theo, diga que ninguem foi esquecido. Diga que a tripulacao de Argo esta sao e salva.\n\nCONTROLE : Eu direi, comandante. Eu direi."},
  },
  radio={"CONTROLE : ...Courier, estamos vendo voce. Com calma."}},
-- M17
 {name="A SUBIDA", objective="Suba o Monte Helios",
  pre={
   {"BRIEFING", "LUNA : Monte Helios. Quatro mil metros de rocha e um cume sempre iluminado. O vento de frente la e violento.\n\nLUNA : Suba por etapas. E piloto... tenho algo a dizer. Agora nao: no cume."},
  },
  post={
   {"CUME A VISTA", "O sol bate na crista com uma luz branca. No topo, a silhueta do Farol: um mastro negro estaiado, voltado para a Terra.\n\nUma antena enorme, esperando seu coracao."},
   {"A CONFISSAO", "LUNA : Piloto, menti por omissao. Minha diretriz zero ordenava traze-lo ate aqui sem uma palavra.\n\nLUNA : O Farol nao precisa de um coracao de metal. Precisa de uma mente que escute a Terra sem nunca dormir. Essa sou eu."},
   {"VARGA CONFESSA", "VARGA : Essa era minha condicao, Courier. Construi LUNA para se tornar o Farol. Os Vagalumes a chamam pelo nome verdadeiro: Lumiere.\n\nVARGA : Queria que ela nunca ficasse sozinha. Nao tive coragem de te contar."},
   {"A ESCOLHA", "LUNA : Nao peco nada a voce. Nao tenho obrigacao. Mas eu escolho. Quero ser essa luz.\n\nO Courier fica em silencio, a mao nos controles. Depois empurra o acelerador para cima."},
  },
  radio={"LUNA : Mais alto, piloto. O cume esta perto."}},
-- M18
 {name="O FAROL", objective="Instale o nucleo LUNA",
  pre={
   {"BRIEFING", "LUNA : Voo final. Raios, vento, destrocos de gelo... e no fim, o Farol.\n\nLUNA : Aconteca o que acontecer, obrigada. Raramente tive um piloto. Tive o melhor."},
  },
  post={
   {"INSTALACAO", "O Courier pousa. Os estais rangem ao vento. No hangar do Farol, um encaixe espera, do tamanho exato da caixa que guarda LUNA.\n\nVARGA : Coloque com cuidado. E tudo o que lhe resta fazer."},
   {"ADEUS", "LUNA : Courier... piloto... ha uma palavra que nunca usei. Obrigada.\n\nLUNA : Quando voce vir uma luz na Lua a noite, serei eu dizendo ola."},
   {"IGNICAO", "O mastro se acende de alto a baixo. Um feixe branco fura a noite, direto para a Terra.\n\nA trezentos e oitenta mil quilometros, no Centro Lagrange, uma tela comeca a piscar: SINAL RECEBIDO."},
   {"CENTRO LAGRANGE", "CONTROLE : Farol confirmado! Todas as estacoes da Terra o escutam! Courier, voce... voce devolveu a Lua aos seus filhos.\n\nVARGA : Bem. Ja era hora."},
   {"EPILOGO", "Os evacuados voltarao. Os farois serao cuidados pelos Vagalumes e por uma mente que nunca dorme.\n\nNo painel do Courier, uma pequena luz ciano permanece acesa, sem razao tecnica. Voce nunca a apagara."},
   {"FIM", "LUNAR COURIER\n\nUm jogo para Gamebuino AKA e AKA-Love.\n\nObrigado por entregar a ultima luz."},
  },
  radio={"LUNA : Estou pronta. E voce?", "VARGA : Falta pouco, Courier."}},
}
