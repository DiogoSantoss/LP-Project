O objetivo deste projecto é escrever um programa em PROLOG para resolver puzzles de
palavras cruzadas, de agora em diante designados apenas por "puzzles".

# 1 Representação de puzzles
Um puzzle é representado por uma lista de dois elementos:
• O primeiro elemento é uma lista de palavras,
• O segundo elemento é uma grelha.
Uma grelha de dimensão n × m é representada por uma lista de n listas de m elementos,
em que cada uma das n listas representa uma linha do puzzle. Cada elemento é por sua
vez:
• uma variável, se a posição correspondente do puzzle não estiver preenchida,
• o valor da posição correspondente do puzzle, se esta estiver preenchida,
• o símbolo "#", se a posição estiver a negro.
Por exemplo, o puzzle da Fig. 1 é representado por
[[ato,dao,dia,mae,sede,soar,ameno,drama,mande],
[[P11, P12, P13, #, P15, P16, P17, P18],
[P21, #, P23, P24, P25, #, P27, #],
[P31, #, P33, #, P35, a, P37, #],
[P41, P42, P43, P44, P45, #, #, #],
[P51, #, P53, #, #, #, #, #]]]
# 2 Abordagem
Nesta secção apresentamos o algoritmo que o seu programa deve usar na resolução de
puzzles.
## 2.1 Inicialização
O primeiro passo na resolução de um puzzle consiste na sua inicialização. Em alguns
casos, este passo é suficiente para resolver o puzzle.
Para inicializar um puzzle, devem ser seguidos os seguintes passos:
1. Obter uma lista ordenada cujos elementos são listas com as letras de cada palavra.
Por exemplo, para o puzzle da Fig. 1 esta lista seria
[[a,m,e,n,o],[a,t,o],[d,a,o],[d,i,a],[d,r,a,m,a],
[m,a,e],[m,a,n,d,e],[s,e,d,e],[s,o,a,r]]
Pág. 5 de 23
2. Obter uma lista com os espaços disponíveis na grelha, aos quais podem ser atribuídas palavras. Considere que um espaço tem pelo menos três posições.1 A lista deve
estar ordenada de forma a apresentar os espaços da primeira para a última linha, e
da esquerda para direita, seguidos dos espaços da primeira para a última coluna, e
de cima para baixo. Por exemplo, para o puzzle da Fig. 1 esta lista seria
[[P11, P12, P13], [P15, P16, P17, P18],
[P23, P24, P25],
[P35, a, P37],
[P41, P42, P43, P44, P45],
[P11, P21, P31, P41, P51],
[P13, P23, P33, P43, P53],
[P15, P25, P35, P45],
[P17, P27, P37]]
3. Obter a lista de palavras possíveis para cada espaço. Esta lista será daqui em diante
designada por lista de palavras possíveis. Uma palavra Pal é possível para um espaço
Esp se:
• Pal e Esp tiverem o mesmo comprimento.
• Pal respeitar as letras que já estejam atribuídas a elementos de Esp. Por exemplo, a palavra ato não é possível para o espaço [P35, a, P37].
• A colocação de Pal em Esp não impossibilitar o preenchimento de outros espaços com posições em comum com Esp. Por exemplo, a palavra ato não é
possível para o espaço [P11, P12, P13], porque a posição P13 ficaria preenchida com o, esta posição é a primeira do espaço [P13, P23, P33, P43, P53], e
não existe nenhuma palavra de 5 letras começada por o.
O resultado deste passo consiste numa lista em que cada elemento é uma lista de 2
elementos: um espaço e a lista (ordenada) de palavras possíveis para esse espaço.
Por exemplo, para o puzzle da Fig. 1 a lista de palavras possíveis seria
[[[P11, P12, P13], [[d, i, a]]],
[[P15, P16, P17, P18], [[s, e, d, e], [s, o, a, r]]],
[[P23, P24, P25], [[a, t, o], [m, a, e]]],
[[P35, a, P37], [[d, a, o]]],
[[P41, P42, P43, P44, P45], [[m, a, n, d, e]]],
[[P11, P21, P31, P41, P51], [[d, r, a, m, a], [m, a, n, d, e]]],
[[P13, P23, P33, P43, P53], [[a, m, e, n, o]]],
[[P15, P25, P35, P45], [[s, e, d, e]]],
[[P17, P27, P37], [[a, t, o], [d, a, o]]]]
4. Simplificar a lista de palavras possíveis. Para tal devem ser seguidos os seguintes
passos:
(a) Atribuir letras comuns a todas as palavras possíveis. Se todas as palavras possíveis para um espaço tiverem uma letra em comum numa dada posição, essa
posição do espaço deverá ser preenchida com essa letra. Por exemplo, suponhamos que as palavras possíveis para o espaço [X, Y, Z, W] são [[m, a,
1
Isto quer dizer que todas as palavras a colocar num puzzle têm pelo menos 3 letras.
Pág. 6 de 23
n, a], [m, o, n, o]]; então o espaço deve ser actualizado para [m, Y,
n, W]. Como resultado da aplicação deste passo, a lista de palavras possíveis
anterior, seria actualizada para:
[[[d, i, a], [[d, i, a]]],
[[s, P16, P17, P18], [[s, e, d, e], [s, o, a, r]]],
[[m, P24, e], [[a, t, o], [m, a, e]]],
[[d, a, o], [[d, a, o]]],
[[m, a, n, d, e], [[m, a, n, d, e]]],
[[d, P21, P31, m, P51], [[d, r, a, m, a], [m, a, n, d, e]]],
[[a, m, e, n, o], [[a, m, e, n, o]]],
[[s, e, d, e], [[s, e, d, e]]],
[[P17, P27, o], [[a, t, o], [d, a, o]]]]
(b) Retirar palavras impossíveis: depois do passo anterior, pode acontecer que algumas listas de palavras possíveis para um espaço contenham palavras que
deixaram de ser possíveis para esse espaço. É o que acontece com o terceiro
elemento da lista da alínea anterior: a palavra [a, t, o] deixou de ser possível, e consequentemente, deve ser retirada da lista. Como resultado da aplicação deste passo, a lista de palavras possíveis anterior, seria actualizada para:
[[[d, i, a], [[d, i, a]]],
[[s, P16, P17, P18], [[s, e, d, e], [s, o, a, r]]],
[[m, P24, e], [[m, a, e]]],
[[d, a, o], [[d, a, o]]],
[[m, a, n, d, e], [[m, a, n, d, e]]],
[[d, P21, P31, m, P51], [[d, r, a, m, a]]],
[[a, m, e, n, o], [[a, m, e, n, o]]],
[[s, e, d, e], [[s, e, d, e]]],
[[P17, P27, o], [[a, t, o], [d, a, o]]]]
(c) Retirar palavras únicas: se uma palavra é a única palavra possível para um
espaço, então essa palavra deve ser retirada das restantes listas de palavras
possíveis. Como resultado da aplicação deste passo, a lista de palavras possíveis anterior, seria actualizada para:
[[[d, i, a], [[d, i, a]]],
[[s, P16, P17, P18], [[s, o, a, r]]],
[[m, P24, e], [[m, a, e]]],
[[d, a, o], [[d, a, o]]],
[[m, a, n, d, e], [[m, a, n, d, e]]],
[[d, P21, P31, m, P51], [[d, r, a, m, a]]],
[[a, m, e, n, o], [[a, m, e, n, o]]],
[[s, e, d, e], [[s, e, d, e]]],
[[P17, P27, o], [[a, t, o]]]]
Estes 3 passos devem ser repetidos até não haver nenhuma modificação na lista de
palavras possíveis.
## 2.2 Resolução de listas de palavras possíveis
Se após a inicialização de um puzzle restarem posições por preencher, isto é, se ainda
existirem espaços com variáveis, devem seguir-se os seguintes passos:
Pág. 7 de 23
1. Identificar os espaços que tiverem listas de palavras possíveis com mais de uma
palavra. De entre estes espaços escolher o primeiro que tenha associado um número
mínimo de palavras possíveis. Por exemplo, suponhamos que tínhamos a seguinte
lista de palavras possíveis:
[[espaço1, [palavra11, palavra12, palavra13]],
[espaço2, [palavra21, palavra22]],
[espaço3, [palavra31]],
[espaço4, [palavra41, palavra42]]]
Os espaços com listas de palavras possíveis com mais de uma palavra são espaço1,
espaço2,espaço4. Destas, espaço2,espaço4 têm o número mínimo de palavras possíveis: dois. Logo, será escolhido o espaço espaço2.
2. Experimentar atribuir uma palavra ao espaço escolhido. Suponhamos que um dos
elementos da lista de palavras possíveis era
[[c,a,l,_160,m],[[c,a,l,a,m],[c,a,l,e,m]]]. Após a aplicação deste
passo, este elemento seria substituído por [[c,a,l,a,m],[[c,a,l,a,m]]].
3. Simplificar a lista de palavras possíveis, como indicado no passo 4, da Secção 2.1.
Estes 3 passos devem ser repetidos enquanto existirem espaços com um número de palavras possíveis superior a um. Se a atribuição de uma palavra a um espaço levar a uma
situação impossível, retrocede-se até à última escolha. Note que o mecanismo de retrocesso do PROLOG faz precisamente isto.
## 2.3 Resolução de puzzles
Finalmente, e usando os algoritmos anteriormente descritos, para resolver um puzzle
basta em primeiro lugar proceder à inicialização, obtendo a lista de palavras possíveis
simplificada, e em seguida resolver esta lista.

