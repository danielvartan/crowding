;permanencia, capacidade_maxima, modificador_max_1, vertice_modificador_1, modificador_max_2, vertice_modificador_2, desvio_padrao_permanencia, desvio_padrao_entrada, taxa_entrada
globals [porcentagem_cheio ticks_cheio total_pessoas acumulador]
turtles-own [tempo tempo_permanencia]


;Configura as ações do programa pelo botão executar.
to main
  ;estabelece a cor de fundo dos patches.
  ask patches [set pcolor black]

  ;elimina as turtles que atingem seu tempo de permanencia e colore as que estão prestes a morrer.
  ask turtles [
    if tempo >= tempo_permanencia [die]
    if tempo > 0.9 * tempo_permanencia [set color white]
    ]
  
  ;atualiza as pessoas - mexe e atualiza o tempo.
  ask turtles
  [
    fd 0.5
    rt random 50
    lt random 50
    set tempo tempo + 1
  ]
  
  ;Vê se o valor do modificador_1, ou o vertice, é maior que o máximo permitido.
  if modificador_max_1 > modificador_max_2 [set modificador_max_1 modificador_max_2]
  if vertice_modificador_1 >= vertice_modificador_2 [set vertice_modificador_1 vertice_modificador_2 - 1]
  
  ;Calcula de forma homogênea a taxa de entrada, respeitando a capacidade maxima e aplicando o modificador.
  let taxa_modificada taxa_entrada * calcula_modificador (count turtles / capacidade_maxima * 100)
  set taxa_modificada random-normal taxa_modificada (taxa_modificada * desvio_padrao_entrada / 100)
  set acumulador (acumulador + taxa_modificada)
  let adicionar int acumulador
  if adicionar + count turtles > capacidade_maxima [ set adicionar capacidade_maxima - count turtles ]
  create-turtles adicionar [set color yellow setxy random-xcor random-ycor set tempo 0 set tempo_permanencia random-normal permanencia (permanencia * desvio_padrao_permanencia / 100) set shape "person"]
  set acumulador acumulador mod 1
  set-current-plot "Taxa de Entrada"
  plotxy ticks adicionar
  
  ;Desenha o grafico do modificador e das pessoas (caso isso não ocorra, significa que o sistema ainda não foi inicializado).
  desenhar_modificador
  set-current-plot "pessoas"
  carefully [plotxy ticks count turtles] [limpar]
  
  ;Realiza as contas de "% de Tempo Cheio" e "Média de Pessoas"
  contas
  
  ;Se ocorrer um erro no tick é em razão do não preparo prévio do sistema.
  carefully [tick] [limpar tick]
end

to-report calcula_modificador [porcentagem]
  ;Cria a variável de retorno e usa as variaveis globais modificador_max_n como máximos.
  let modificador_entrar 1
  let modificador_max_2_local modificador_max_2 - 1
  let modificador_max_1_local modificador_max_1 - 1
  
  ;Se a porcentagem for menor ou igual ao primeiro vértice, o sistema usa essa função pra calcular o modificador.
  if porcentagem <= vertice_modificador_1
  [
    set modificador_entrar porcentagem * (modificador_max_1_local / vertice_modificador_1) + 1
  ]
  ;Se for maior que o primeiro, mas menor que o segundo, o sistema utiliza a função abaixo.
  if porcentagem > vertice_modificador_1 and porcentagem < vertice_modificador_2
  [
    let a (modificador_max_2_local - modificador_max_1_local) / (vertice_modificador_2 - vertice_modificador_1)
    let b modificador_max_2_local - (vertice_modificador_2 * a)
    set modificador_entrar (a * porcentagem + b + 1)
  ]
  ;Se for maior ou igual ao segundo, o sistema usa a função abaixo.
  if porcentagem >= vertice_modificador_2
  [
    let a modificador_max_2_local / (vertice_modificador_2 - 100)
    let b modificador_max_2_local - (a * vertice_modificador_2)
    set modificador_entrar (a * porcentagem + b + 1)
  ]
  
  report modificador_entrar
end



to contas
  ;Calcula % de tempo cheio. Se o ticks forem igual a 0 ocorre um erro e não se cacula nada.
  if count turtles >= capacidade_maxima [set ticks_cheio ticks_cheio + 1]
  carefully [set porcentagem_cheio ticks_cheio / ticks * 100] []
  
  ;Calcula a média de pessoas.
  set total_pessoas total_pessoas + count turtles
end



to desenhar_modificador
  ;Desenha o plot de maneira correta, limpa. Atualiza a escala (se der erro não se calcula nada)
  ;e cria a variável porcentagem que vai ser usada no loop.
  set-current-plot "modificador"
  clear-plot
  carefully [set-plot-y-range 1 modificador_max_2] [stop]
  let porcentagem 0
  
  ;Repete esse bloco 101 vezes, ou seja, do valor 0 ao 100.
  repeat 101
  [
    ;Plota o valor encontrado para essa % e a soma em 1, com o fim de encontrar o modificador do proximo valor.
    plotxy porcentagem (calcula_modificador porcentagem)
    set porcentagem porcentagem + 1
  ]
end

;Configura os botões de preparo e cenários.
to limpar
  __clear-all-and-reset-ticks
  reset-ticks
end

;Configura os controladores do Cenário 1.
to default_cenario-1
  display
  set taxa_entrada 0.9
  set permanencia 60
  set capacidade_maxima 100
  set desvio_padrao_entrada 0
  set desvio_padrao_permanencia 0
  set vertice_modificador_1 30
  set modificador_max_1 1.3
  set vertice_modificador_2 70
  set modificador_max_2 2.5
  limpar
end

;Configura os controladores do Cenário 2.
to default_cenario-2
  no-display
  set taxa_entrada 30
  set permanencia 120
  set capacidade_maxima 4600
  set desvio_padrao_entrada 0
  set desvio_padrao_permanencia 0
  set vertice_modificador_1 30
  set modificador_max_1 1.6
  set vertice_modificador_2 70
  set modificador_max_2 2.6
  limpar
end

;Configura os controladores do Cenário 3.
to default_cenario-3
  no-display
  set taxa_entrada 1.2
  set permanencia 45
  set capacidade_maxima 385
  set desvio_padrao_entrada 89
  set desvio_padrao_permanencia 15
  set vertice_modificador_1 19
  set modificador_max_1 1.0
  set vertice_modificador_2 22
  set modificador_max_2 2.0
  limpar
end
@#$#@#$#@
GRAPHICS-WINDOW
10
10
374
395
16
16
10.73
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
0
ticks
30.0

SLIDER
400
95
685
128
permanencia
permanencia
15
180
45
5
1
min
HORIZONTAL

SLIDER
400
135
685
168
capacidade_maxima
capacidade_maxima
1
5000
385
1
1
pessoas
HORIZONTAL

BUTTON
400
10
488
46
Executar
main
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
494
10
580
46
Preparar
limpar
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
400
310
740
495
Pessoas
tempo
pessoas
0.0
0.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

MONITOR
400
255
527
300
% de Tempo Cheio
porcentagem_cheio
2
1
11

MONITOR
535
255
649
300
Média de Pessoas
total_pessoas / ticks
2
1
11

MONITOR
720
255
777
300
Tempo
ticks
0
1
11

PLOT
750
310
980
490
Modificador
% cheio
modificador
0.0
100.0
1.0
1.1
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SLIDER
695
175
980
208
modificador_max_2
modificador_max_2
1
100
2
0.1
1
NIL
HORIZONTAL

SLIDER
695
134
980
167
vertice_modificador_2
vertice_modificador_2
1
99
22
1
1
NIL
HORIZONTAL

SLIDER
695
55
980
88
vertice_modificador_1
vertice_modificador_1
1
vertice_modificador_2 - 1
19
1
1
NIL
HORIZONTAL

SLIDER
695
95
980
128
modificador_max_1
modificador_max_1
1
modificador_max_2
1
0.1
1
NIL
HORIZONTAL

SLIDER
400
54
685
87
taxa_entrada
taxa_entrada
0
40
1.2
0.1
1
pessoas/min
HORIZONTAL

SLIDER
400
214
685
247
desvio_padrao_permanencia
desvio_padrao_permanencia
0
200
15
1
1
%
HORIZONTAL

MONITOR
656
255
713
300
Pessoas
count turtles
0
1
11

MONITOR
785
255
893
300
% da Casa Cheia
count turtles / capacidade_maxima * 100
0
1
11

SLIDER
400
175
685
208
desvio_padrao_entrada
desvio_padrao_entrada
0
200
89
1
1
%
HORIZONTAL

BUTTON
586
10
678
47
Cenário 1
default_cenario-1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
683
10
775
47
Cenário 2
default_cenario-2
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
780
10
872
47
Cenário 3
default_cenario-3
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
400
505
740
685
Taxa de Entrada
tempo
taxa_entrada
0.0
0.0
0.0
0.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

@#$#@#$#@
## Sobre o Modelo

Ao se observar de forma atenta a movimentação de restaurantes e bares, podemos notar alguns padrões de funcionamento. Um dos padrões mais notados entre donos e gerentes de estabelecimentos de alimentos/ bebidas, é a significativa influência que a quantidade de pessoas presentes no estabelecimento exerce sobre as outras que os veem de fora. Por essa razão, é comum que a hostess da casa receba a orientação de direcionar os clientes à praças onde se possa enxergar o público interno, geralmente locais próximos da porta. Outra estratégia também comum é a formação intencional de filas externas e bares de recepção/espera abertos ou bem visíveis à rua, enquanto o restante do restaurante é fechado aos olhos de quem está de fora, a fim de concentrar a influência das pessoas naquele espaço.


>![Figura 1] (file:imagens/figura_01.jpg)
>
>**Figura 1**: Fachada do restaurante italiano Piola, unidade de Houston, Texas, EUA.


>![Figura 2] (file:imagens/figura_02.jpg)
>
>**Figura 2**: Fila externa do bar/balada Sonique, unidade de São Paulo.


Esse caráter imitativo do ser humano é citado por Mark Buchanan em seu livro “O Átomo Social”. Segundo Buchanan, “somos totalmente interdependentes  e incorporados em uma grossa tapeçaria social de outros, como átomos em um líquido denso” (BUCHANAN, 2007 – Tradução Livre). Trabalhando sob essa óptica, Buchanan discorre a respeito do ser humano e o define como fruto de uma organização social/cultural, com comportamentos coletivos semelhantes aos que ocorrem com outros animais ou mesmo partículas, como átomos. Indo mais a fundo, Buchanan demonstra que um dos motores-chave dos fenômenos advindos desse comportamento coletivo é a imitação, imitação essa que pode e é explorada em diversos meios, como bares e restaurantes.

Partindo dos fatos observados e da teoria da física social proposta por Buchanan, este modelo simula o sistema complexo citado acima, tratando da influência em que o número de pessoas de um bar/restaurante tem no processo de decisão na entrada de novas pessoas no estabelecimento. Sendo estudado a razão entre o número de pessoas no bar/restaurante e a taxa de entrada de novos clientes.



## Como se usa?

O modelo consiste nas interações de apenas um agente, as pessoas, e seu cenário é um bar/restaurante em horário de pico, como nos primeiros horários da janta (ex: 19:00h) ou almoço (ex: 13:00h). Esse mesmo estabelecimento se encontra isolado da concorrência, ou seja, se considera que não haja nenhum outro comércio da categoria próximo a ele.

Ao lado direito se dispõe os controladores, monitores e gráficos do modelo assim como os botões “Executar”, “Preparar”, “Cenário 1”, “Cenário 2” e “Cenário 3”. Pressionando o botão “Preparar” e em seguida o botão “Executar”, podemos ver o conteúdo do quadro ilustrativo à esquerda, em que se tem o bar/restaurante definido pelo fundo preto, enquanto as pessoas, em amarelo, entram e saem do seu interior. No mesmo quadro, conforme o tempo passa, pode-se observar que algumas dessas pessoas se tornam de cor branca, isso significa que essas estão prestes a sair, restando apenas 10% de seu tempo de permanência no local.

À direita do modelo há os itens de maior importância: os botões, controladores, monitores e gráficos.  Abaixo é descrito suas funções, discriminando cada um deles.


###Botões###

* **Preparar**: Prepara as configurações e limpa o cenário para a ação.

* **Executar**: Aciona o modelo.

* **Cenário 1**, **Cenário 2** e **Cenário 3**: Configura os controladores para valores pré-definidos, a fim de se observar comportamentos notáveis.


###Controladores###

* **taxa_entrada**: Define a quantidade de pessoas que adentram o bar/restaurante por minuto.

* **permanencia**: Define a quantidade de tempo em minutos das pessoas que adentraram o estabelecimento.

* **capacidade_maxima**: Define a quantidade de pessoas que o estabelecimento suporta.

* **desvio_padrao_entrada**: Define a aleatoriedade da taxa de entrada (controlador “taxa_entrada”), partindo de uma distribuição probabilística gaussiana, conhecida também como distribuição normal.

* **desvio padrão_permanencia**: Define a aleatoriedade do tempo de permanência (controlador “permanência”) pela mesmo tipo de distribuição do “desvio_padrao_entrada”.

* **vertice_modificador_1**, **modificador_max_1**, **vertice_modificador_2**, **modificador_max_2**: Trata-se de controladores do modificador, que define três intervalos de influência (1 à x;x à y;y à 1) que, a partir de seus valores, multiplicam o valor da “taxa_entrada”.


###Monitores###

* **% de Tempo Cheio**: Reporta a porcentagem na qual o estabelecimento ficou cheio em razão de todo tempo percorrido.

* **Média de Pessoas**: Reporta o total das pessoas que adentraram a casa em razão de todo tempo percorrido.

* **Pessoas**: Reporta a quantidade de pessoas presentes no bar/restaurante em no estado atual do modelo.

* **Tempo**: Reporta o tempo percorrido em minutos.

* **% da Casa Cheia**: Reporta a porcentagem de ocupação do bar/restaurante em relação à sua capacidade máxima.


###Gráficos###

* **Pessoas**: Reporta em tempo real a relação de pessoas pelo tempo percorrido em um plano cartesiano.

* **Modificador**: Reporta, de maneira gráfica, os intervalos de influência, dados pela configuração do modificador.

* **Taxa de Entrada**: Reporta em tempo real a relação entre a taxa de entrada e o tempo percorrido em um plano cartesiano.


Para conhecer mais a respeito do funcionamento do modelo, veja o tópico **Como Funciona?**.



## Como funciona?

O modelo se dá basicamente a partir de três variáveis: **taxa_entrada**, **permanência** e **capacidade_maxima**. Essas três variáveis se apresentam de forma constante, de comportamento linear, ou seja, a partir do momento que essas são configuradas, seus valores no modelo executado são fixos.

Para o cálculo da variável **taxa_entrada** é utilizado um **acumulador**, dispositivo que acumula partes de pessoas e adiciona apenas pessoas inteiras ao modelo. Ou seja, se a “taxa_entrada” estiver configurada para adicionar 0,6 pessoas/min, no primeiro minuto o “acumulador” não adicionará ninguém ao quadro, pois não há como adicionar apenas 0.6 pessoas. Porém já no próximo minuto, acumulado 1,2 pessoas, o acumulador adicionará 1 pessoa, deixando a 0.2 pessoas separadas para uma novo tempo, e assim sucessivamente.

Com a presença do acumulador é criado um pequeno ruído nos gráficos que deve ser desconsiderado. Esse ruído se dá pelos intervalos ocorridos no próprio acumulador. Se a “taxa_entrada” não for um número inteiro e sim um número “quebrado”, ocorrerá que em alguns intervalos nenhuma pessoa entrará de fato no restaurante, fazendo com que o gráfico “Pessoas” tenham um leve ruído, como representado na figura 3 a seguir.


>![Figura 3] (file:imagens/figura_03.jpg)
>
>**Figura 3**: Ruído causado pelo acumulador nos gráficos “Pessoas” e “Taxa de Entrada”. (“taxa_entrada” = 0,9 pessoas/min ; “permanência” = 60 min; desvios =  0%; modificador inativo).


A partir das três variáveis constantes, temos um comportamento linear no gráfico **Pessoas** (Figura 3). Isso se modifica a partir do momento em que adicionamos um desvio padrão nas variáveis "taxa_entrada" e "permanencia" pelos controladores **desvio_padrao_entrada** e **desvio_padrao_permanencia**. O desvio padrão é calculado pela distribuição de Gauss, também chamada de distribuição “Normal”, como representado na figura 4 a seguir.


>![Figura 4] (file:imagens/figura_04.jpg)
>
>**Figura 4**: Distribuição Normal/Gaussiana.


O desvio é posto pela porcentagem da variável na qual ele é aplicado, ou seja, se ele é aplicado à “taxa_entrada”, calcula-se o desvio pela porcentagem aplicada em relação ao valor da variável constante.

>![Figura 5] (file:imagens/figura_05.jpg)
>
>**Figura 5**: Sem desvio/constante.


>![Figura 6] (file:imagens/figura_06.jpg)
>
>**Figura 6**: Com desvio/aleatória.


O desvio causa uma aleatoriedade nas variáveis, tornando elas inconstantes a uma certa amplitude configurada pelo controlador. Essa aleatoriedade causa um ruído que é apresentado no gráfico “Pessoas”  como no gráfico “Taxa de Entrada” (apenas quando ele for aplicado à variável “taxa_entrada”) por uma distorção de altos e baixos na linha desenhada.


>![Figura 7] (file:imagens/figura_07.jpg)
>
>**Figura 7**: Ruído causado pelo desvio padrão nos gráficos “Pessoas” e “Taxa de Entrada”.


Por fim temos o **modificador**, que calcula a influência das pessoas presentes na casa em relação à taxa de entrada do modelo. Em termos matemáticos, o “modificador”, a partir de uma porcentagem da casa cheia, multiplica um valor "z" ao valor do controlador “taxa_entrada”, fazendo que a linha do gráfico "Pessoas" e "Taxa de Entrada" cresça de maneira exponencial.

O “modificador” tem três intervalos distintos de influência no quais são multiplicados valores diferentes. Esses intervalos são representados no gráfico **Modificador** e seu primeiro intervalo consiste em uma multiplicação linear de um valor que vai de 1 à “x”. “x” é delimitado pelo controlador “modificador_max_1”. O segundo intervalo consiste em uma multiplicação linear de valor que vai de “x” à “y”. Sendo ”y” delimitado pelo controlador “modificador_max_2”. Seu último intervalo consiste em uma multiplicação linear de valores que vão de “y” à 1. Ressaltando que quando o valor do modificador chega a “1” ele não tem nenhuma influência sobre a taxa de entrada, já que um número multiplicado por 1 é ele mesmo.

O gráfico do modificador se dá por um plano cartesiano onde se tem como ordenada “modificador” (valor que será multiplicado) e como abcissa “% cheio” (valor da porcentagem de quanto a casa está cheia). As configurações do eixo “modificador” foram explicadas no parágrafo acima. As configurações da abscissa “% cheio” se dá por dois controladores. Para calcular o ponto/vértice que separa os intervalos  “1 a x” e “x a y” se utiliza o controlador chamado “vertice_modificador_1”. Para calcular o ponto/vértice que separa os intervalos “x a y” e “y a 1” se utiliza o controlador “vertice_modificador_2”. A configuração de cada ponto/vértice define a porcentagem de casa cheia que se dará a multiplicação configurada nos controladores “modificador_max_1” e “modificador_max_2”.


>![Figura 8] (file:imagens/figura_08.jpg)
>
>**Figura 8**: Representação gráfica do “modificador”, considerando as configurações no qual a multiplicação da “taxa_entrada” é de 1 à 1,3 até que a casa fique 30% cheia; 1,3 à 2,5 até 70% de casa cheia; e de 2,5 à 1 até 100% de casa cheia.



## Comportamentos Notáveis

Podemos chegar a diferentes cenários executando o modelo e modificando os valores de seus controladores. Dentre esses diversos cenários possíveis, foram selecionados três deles por seus aspectos notáveis. Esses cenários estão pré-configurados nos botões **Cenário 1**, **Cenário 2** e **Cenário 3**. Abaixo é detalhado o comportamento de cada um deles.


###Cenário 1###

Neste cenário pode-se observar que os tipos de desvio estão com valor 0, ou seja, não há nenhum desvio na taxa de entrada das pessoas, assim como seu tempo de permanência. O único fator de influência é o modificador, que atua diretamente na variável “taxa_entrada”.

Chamamos esse cenário de _baby boom_ pois ele se inicia com um grande aumento exponencial do número de pessoas no bar/restaurante. Nele podemos observar no gráfico “Pessoas” esse crescimento exponencial e, a partir dos 60 minutos, um decrescimento representado com uma curva suave no gráfico, dado por um depressão na linha e logo após um novo e leve crescimento seguido por um depressão menor e assim sucessivamente, chegando a um equilíbrio de entrada e saída de pessoas mantendo a casa cerca de 90% cheia.


>![Figura 9] (file:imagens/figura_09.jpg)
>
>**Figura 9**: Representação dos gráficos e monitores do “Cenário 1”.


No cenário, o valor da variável “permanência” é de 60 min., e o modificador está configurado para multiplicar a taxa de entrada pelos valores de “1” à “1,3” até a casa estar 30% cheia; “1,3” à “2,5” até a casa estar 70% cheia e “2,5” à “1” até a casa estar 100% cheia. A partir desses dados, podemos entender a razão de tal comportamento.

Podemos observar que a partir dos 60 minutos, há uma mudança no crescimento da curva “Pessoas”, ela começa a diminuir seu crescimento. Isso se dá porque as pessoas que entraram no primeiro minuto começam a sair do estabelecimento e a influência do modificador diminui, pois com a casa 70% cheia a taxa de crescimento ora alta começa a se torna mais baixa progressivamente.

Aos 90 minutos há o ápice de crescimento seguido de uma grande depressão na linha do gráfico “Pessoas” com a casa 90% cheia, caindo ao máximo aos 120 minutos, com a casa 82,3% cheia, tempo no qual as pessoas que entraram a partir dos 60 minutos começam a sair do estabelecimento.

A partir dos 120 minutos o modificador exerce uma influência maior do que aos 90 minutos, dando força para o crescimento da taxa de entrada, fazendo com que cresça novamente o número de pessoas no bar/restaurante. Isso pode ser observado no gráfico “Taxa de Crescimento”, no qual, no período, a taxa permanece alta, com poucos picos baixos.

O crescimento observado a partir dos 120 minutos segue o mesmo comportamento do crescimento anterior, porém não chega ao maior valor do primeiro crescimento. Novamente há uma diminuição da taxa de entrada, causando uma nova depressão na linha à partir dos 166 minutos. Seguindo de um crescimento cada vez menor e queda cada vez menor no número de pessoas, até que o número de pessoas presentes no estabelecimento se torna estável em cerca de 90% da casa cheia.

É importante notar que a casa, mesmo estando boa parte cheia, nunca chegar a estar 100% cheia. Há uma "luta" entre a saída/entrada de pessoas e a influência maior/menor do modificador, criando oscilações na quantidade de pessoas do bar/restaurante, chegando mais a frente a um equilíbrio. Esse cenário demonstra como uma casa pode se manter com um constante número de pessoas, mesmo considerando essa oscilação entra entrada/saída das pessoas do local.



###Cenário 2###

Ao se executar o cenário 2 o modelo automaticamente desativa o quadro ilustrativo, pois as configurações do cenário fazem com que as imagens do quadro se tornem difíceis de renderizar.

O cenário tem um comportamento muito semelhante ao cenário 1, porém dessa vez se especula uma casa com uma capacidade máxima de pessoas muito maior (4600 pessoas), assim como um aumento na taxa de entrada  (30 pessoas/min.) e no tempo de permanência (120 min.).

Como no cenário anterior, os desvios estão configurados como 0, ou seja, as taxas são constantes, sendo modificada apenas a variável “taxa_entrada” pelo “modificador”, que está configurado da seguinte forma: intervalo 1 de “1” à “1,6”, de 0% de casa cheia ao vértice 1 em 30% de casa cheia; intervalo 2 de “1,6” à “2,6”, de 30% de casa cheia ao vértice 2 em 70% de casa cheia; e intervalo 3 de “2,6” à “1”, de 70% de casa cheia ao ponto final de 100% da casa cheia.

Pode-se observar no cenário um crescimento exponencial vertiginoso que atinge seu ponto máximo aos 93 minutos, fazendo com que a casa se encha por completo (4600 pessoas). Após isso ocorre, de forma semelhante ao cenário 1, uma grande depressão na linha do gráfico “Pessoas”, seguida de um crescimento que chega novamente à capacidade máxima da casa ocorrendo em seguida uma nova depressão, dessa vez menor, e assim sucessivamente até chegar em um equilíbrio.


>![Figura 10] (file:imagens/figura_10.jpg)
>
>**Figura 10**: Representação dos gráficos e monitores do “Cenário 2”.


É interessante observar que neste cenário, dado um intervalo maior para que a casa fique cheia, é possível enxergar de forma mais clara o aumento exponencial da taxa de entrada pelo gráfico “Taxa de Entrada”. Aos 93 minutos, com a casa cheia, podemos observar no mesmo gráfico que a “taxa_entrada” cai para “0”, e se mantém assim até que o número de pessoas presentes no estabelecimento seja menor do que a capacidade máxima suportada pela casa, que ocorre aos 122 minutos.

A partir dos 122 minutos as pessoas que entraram a partir do tempo “2” começam a sair, e devido ao grande volume de pessoas que está configurado no modelo, como também pela menor taxa de entrada, dada pelo ausência do modificador já que a casa se encontra 100% cheia, há uma grande queda no número pessoas, causando uma grande depressão na linha do gráfico “Pessoas”.

Aos 192 minutos a queda no número de pessoas chega ao seu ponto máximo, com 3750 pessoas, 81,52% de casa cheia. Antes disso, entre 122 minutos e os 192 minutos, com o decréscimo de pessoas na casa, podemos observar nitidamente o “pulo” que houve na “taxa_entrada” no gráfico “Taxa de Entrada”, pois neste intervalo a influência do “modificador” volta a ser presente, levantando uma nova curva de crescimento que se dará a partir dos 192 minutos.

Aos 192 minutos, a quantidade de pessoas cresce novamente, chegando ao máximo da casa aos 234 minutos. Aos 246 minutos começa uma nova depressão no gráfico “Pessoas”, fazendo com que mais a frente ocorra novamente um novo crescimento. Assim sucessivamente, como em num cabo de guerra em que de um lado está os fatores de saída de pessoas e a baixa influência do modificador e do outro a entrada de pessoas e a alta na influência do modificador, o modelo chega por fim a um equilíbrio.

O interessante deste cenário, por mais que ele seja parecido com o cenário 1, é que os comportamentos de entrada/saída das pessoas são mais extremos, chegando a lotar a casa em certos momentos. As variações das taxas são surpreendentes e muito mais nítidas, e demonstra como uma grande casa, assim como casas noturnas, podem se manter em uma oscilação um tanto vertiginosa no número de pessoas presentes.



###Cenário 3###

O cenário 3 demonstra um comportamento completamente diferente dos dois cenários anteriores. Nele é presente tanto os desvios como o “modificador”, tornando o cenário mais próximo da realidade de certos bares/restaurantes.

Como no cenário 2, o quadro também é desativado, pois a representação gráfica se torna muito difícil de se renderizar, já que neste cenário é necessário que o tempo corra de forma mais rápida.

É configurado um bar/restaurante de porte médio, com capacidade para 385 pessoas, “taxa_entrada” de 1,2 pessoas/min., tempo de permanência de 45 min., desvio de “taxa_entrada” em 89%, desvio no tempo de permanência em 15% e modificador da seguinte forma: intervalo 1 de “1” à “1”, de 0% de casa cheia ao vértice 1 em 19% de casa cheia; intervalo 2 de “1” à “2”, de 19% de casa cheia ao vértice 2 em 22% de casa cheia; e intervalo 3 de “2” à “1”, de 22% de casa cheia ao ponto final de 100% da casa cheia.

A configuração acima cria um cenário muito peculiar, de comportamento bifásico, ou seja, é observado uma oscilação entre os três intervalos do modificador em razão da grande oscilação da taxa de entrada, dada pelo “desvio_padrao_entrada”, e do tempo de permanência, dada pelo "desvio_padrao_permanencia".


>![Figura 11] (file:imagens/figura_11.jpg)
>
>**Figura 11**: Representação dos gráficos e monitores do “Cenário 2”.


É possível notar um grande oscilação no gráfico “Taxa de Entrada”, isso se dá pela presença do desvio padrão sobre a “taxa_entrada”. A quantidade de pessoas que entram no estabelecimento agora entram de forma um tanto aleatória, variando, no caso, de “0” a até “12,6” pessoas/min. Isso causa uma enorme oscilação na taxa de pessoas no restaurante, que dada as configurações do “modificador”, causam um “pulo” constante entre seu intervalo 1 e intervalo 2 e 3.

Nesse cenário, o tempo percorrido para que isso ocorra tem que ser de grandes proporções. Podemos observar que até os 5700 minutos, a taxa de crescimento oscila entre “0” à “5,7” pessoas/min., mantendo a casa por volta de até 19% cheia, assim sem nenhuma influência do “modificador”, já que até 19% seu valor é 1.

O cenário muda drasticamente dos 5700 minutos em diante. As oscilações da “taxa_entrada” e "permanencia" dadas pelos desvios são tantas que a casa atinge mais de 19% de casa cheia, fazendo com que o “modificador” haja imediatamente sobre a “taxa_entrada”, elevando os gráficos “Pessoas” e “Taxa de Entrada” à novos patamares. A partir disso o movimento da casa ganha uma certa estabilidade sob o segundo e terceiro intervalo do modificador, com a casa cheia entre 19% à 36,88%. Porém, a partir dos 8300 minutos, dado a grande oscilação causada pelos desvios, o equilíbrio é desfeito, voltando para porcentagens de casa cheia menores que 19%, trazendo assim o movimento de entrada de pessoas novamente para o intervalo 1 do “modificador”, com taxa de entrada consequentemente menor. Isso se segue sucessivamente, tornando o modelo bifásico.

Esse comportamento é hipotético, porém para quem já teve a experiência de gerenciar um bar/restaurante ele se demonstra real, mesmo que ocorra de forma menos frequente. Por mais que as configurações para que ele ocorra, no modelo, sejam extremas, há um indício que os relatos dados por donos/gerentes de oscilações não usuais no movimento de suas casas tenham uma razão semelhante à demonstrada nessas configurações.



##Considerações Finais##

Reconhecemos que esse modelo é um trabalho em progresso, ainda há outras variáveis a serem exploradas e sintonizadas para que ele represente da melhor forma a realidade. Porém, ele consegue demonstrar que o caráter imitativo em bares e restaurantes é um fator determinante no sucesso de público em um estabelecimento.

Em 2010, com o grande aumento de franquias no Brasil, muitos empreendedores, novos e sem conhecimento da área, não conseguiram manter suas casas em pleno funcionamento, causando o fechamento de boa parte desses estabelecimentos. É notável a importância, principalmente em casas recém-abertas, que haja nelas um esforço de mantê-las sempre com um certo número de pessoas, a fim que novas pessoas possam entrar no novo local, sem que essas terem que ser as “desbravadoras” do novo terreno.

Donos e gerentes de estabelecimentos de alimentos/bebidas tem um bom conhecimento desse fenômeno, sendo muito comum esses estarem presentes quase que todos os dias em suas casas, principalmente nos horários de abertura, fazendo assim uma figuração para que as pessoas não sintam intimidades a entrarem em um lugar vazio, imitando aqueles que já estão presentes.



## Referências Bibliográficas

BUCHANAN, Mark. _**The Social Atom**_: _Why the Rich Get Richer, Cheaters Get Caught, and Your Neighbor Usually Looks Like You_. 1ª Edição - Kindle e-Book. New York, USA: Blooiusbury, 2007.

## Créditos

Armando García Escalona (agarciaescalona@gmail.com) | Curso: Gestão de Políticas Públicas
Daniel Kachvartanian de Azevedo (danvartan@gmail.com) | nº USP: 5931043 - Curso: Marketing
Diego Pereira Alvarez (diego_pa@lavabit.com) | nº USP: 7557310 - Curso: Sistemas de informação)
Rony Souza (rony.rroll@hotmail.com) | Curso: Gestão de Políticas Públicas

Alunos do 1º Semestre de diferentes cursos da Universidade de São Paulo (USP), sob a orientação do Prof. Dr. Camilo Rodrigues Neto, na disciplina ACH0051-52 - Estudos Diversificados I - Modelagem com Multiagentes de Sistemas Complexos.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="permanencia_media">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probabilidade_entrar">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movimento_externo">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacidade_maxima">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
BUTTON
130
50
193
83
sdf
NIL
NIL
1
T
OBSERVER
NIL
A

@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
