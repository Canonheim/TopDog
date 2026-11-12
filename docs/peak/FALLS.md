# Where a miss lands (the rain test)

Three bodies dropped beside and above every challenge's start, followed down the real mountain (`tests/peak_falls.tscn`). A body stops at the first grip it touches (a climber could catch there), rides any current it meets, and is flagged **POCKET** if it comes to rest on slick (a softlock) or **LOST** if it leaves the world. `Lost` is the height given up. The designed cost is the `Miss` column of CHALLENGES.md.

| From | Designed | Ends (3 drops) | Lost (m) |
|---|---|---|---|
| 0.1 El Primer Paso | S | grip near 0.1 at (1, 0); grip near 0.1 at (6, 0); grip near 0.1 at (4, 0) | 2, 2, 4 |
| 0.2 Súbete | S | grip near 0.3 at (-8, 3); grip near 0.2 at (-3, 2); grip near 0.2 at (-6, 2) | 2, 2, 4 |
| 0.3 El Descenso | S | grip near 0.3 at (-11, 2); grip near 0.2 at (-6, 2); grip near 0.3 at (-9, 3) | 3, 3, 4 |
| 1.1 La Galería | S | grip near 1.1 at (-156, -10); grip near 1.1 at (-151, -11); grip near 1.1 at (-154, -12) | 0, 1, 4 |
| 1.2 Escalera Rota | S | grip near 1.2 at (-173, -12); grip near 1.2 at (-168, -12); grip near 1.2 at (-170, -9) | 2, 2, 1 |
| 1.3 Los Tablones | A | grip near 1.3 at (-177, 6); grip near 1.3 at (-171, 6); grip near 1.3 at (-174, 6) | 2, 2, 4 |
| 1.4 La Cuerda del Minero | A | grip near 1.4 at (-191, 6); grip near 1.4 at (-189, 6); grip near 1.4 at (-191, 6) | 1, 2, 4 |
| 1.5 El Cubo | B | grip near 1.5 at (-200, 6); grip near 1.5 at (-197, 6); grip near 1.5 at (-200, 6) | 1, 2, 4 |
| 1.6 Vetas de Lodo | B | grip near 1.5 at (-200, 14); grip near 1.6 at (-195, 26); grip near 1.6 at (-198, 26) | 14, 2, 4 |
| 1.7 El Carrito Loco | A | grip near 1.7 at (-206, 40); grip near 1.7 at (-201, 39); grip near 1.7 at (-203, 40) | 2, 3, 4 |
| 1.8 Las Vigas | A | grip near 1.5 at (-219, -26); grip near 1.8 at (-214, 50); grip near 1.8 at (-216, 50) | 80, 2, 1 |
| 1.9 La Polea Grande | B |  |  |
| 1.10 El Derrumbe | B | grip near 1.10 at (-228, 57); grip near 1.10 at (-223, 58); grip near 1.10 at (-225, 57) | 2, 1, 1 |
| 1.11 La Cortina | A | grip near 1.11 at (-231, 72); grip near 1.11 at (-228, 72); grip near 1.11 at (-231, 72) | 1, 2, 4 |
| 2.1 El Borde | X | grip near 2.1 at (-229, 90); grip near 2.1 at (-226, 90); grip near 2.1 at (-229, 90) | 1, 2, 4 |
| 2.2 La Rueda | B | grip near 2.2 at (-254, 99); grip near 2.2 at (-254, 99); grip near 2.2 at (-254, 99) | 1, 1, 4 |
| 2.3 El Acueducto | B | grip near 2.3 at (-250, 102); grip near 2.3 at (-245, 103); grip near 2.3 at (-247, 101) | 2, 0, 4 |
| 2.4 Brazo de Molino | B | grip near 2.4 at (-231, 112); grip near 2.4 at (-228, 110); grip near 2.4 at (-228, 110) | 0, 1, 4 |
| 2.5 Las Compuertas | B | grip near 2.5 at (-250, 114); grip near 2.1 at (-226, 90) via water; grip near 2.5 at (-247, 112) | 0, 24, 1 |
| 2.6 Cadenas | X | water near 1.5 at (-247, -27); grip near 2.6 at (-254, 118); grip near 2.6 at (-257, 121) | 151, 5, 4 |
| 2.7 El Charco del Pozo | X | grip near 2.7 at (-289, 117); grip near 2.7 at (-284, 117); grip near 2.7 at (-287, 117) | 2, 2, 4 |
| 2.8 Contracorriente | B | grip near 2.8 at (-319, 116) via water; grip near 2.8 at (-320, 118); grip near 2.8 at (-323, 118) | 4, 2, 1 |
| 2.9 Tubería | B | grip near 2.9 at (-349, 120); grip near 2.9 at (-344, 118); grip near 2.9 at (-347, 118) | 0, 2, 4 |
| 2.10 La Cascada Chica | B | grip near 2.10 at (-384, 138); grip near 2.10 at (-379, 138); grip near 2.10 at (-381, 138) | 2, 2, 4 |
| 2.11 La Presa | B | grip near 2.11 at (-428, 154); grip near 2.11 at (-423, 153); grip near 2.11 at (-426, 152) | 0, 1, 4 |
| 3.1 Primer Destello | S | grip near 3.1 at (-415, 176); grip near 3.1 at (-412, 178); grip near 3.1 at (-415, 176) | 1, 0, 4 |
| 3.2 El Espejo | B | grip near 3.2 at (-440, 190); grip near 3.2 at (-435, 189); grip near 3.2 at (-438, 189) | 1, 2, 4 |
| 3.3 Candelabros | A | grip near 3.2 at (-448, 177); grip near 3.3 at (-446, 199); grip near 3.3 at (-446, 199) | 24, 1, 4 |
| 3.4 La Geoda | B | grip near 3.4 at (-427, 208); grip near 3.4 at (-425, 209); grip near 3.4 at (-425, 209) | 2, 1, 4 |
| 3.5 Agujas | A | grip near 3.5 at (-418, 214); grip near 3.5 at (-413, 216); grip near 3.5 at (-415, 214) | 2, 1, 4 |
| 3.6 El Prisma | B | grip near 3.6 at (-387, 224); grip near 3.6 at (-382, 224); grip near 3.6 at (-384, 222) | 0, 0, 4 |
| 3.7 Péndulo de Cuarzo | A | grip near 3.7 at (-373, 232); grip near 3.1 at (-410, 176); grip near 3.7 at (-371, 232) | 2, 58, 4 |
| 3.8 Techo de Vidrio | A | grip near 3.8 at (-345, 232); grip near 3.8 at (-343, 232) | 2, 4 |
| 3.9 La Columna | B | grip near 3.9 at (-322, 249); grip near 3.9 at (-320, 249); grip near 3.9 at (-322, 249) | 1, 2, 4 |
| 3.10 El Salto del Pozo I | P | grip near 3.10 at (-324, 267); grip near 3.10 at (-319, 266); grip near 3.10 at (-322, 266) | 1, 2, 4 |
| 4.1 Sombreros | S | grip near 4.1 at (-291, 264); grip near 4.1 at (-289, 265); grip near 4.1 at (-289, 265) | 2, 0, 2 |
| 4.2 Lianas | S | grip near 4.2 at (-269, 276); grip near 4.2 at (-264, 264); grip near 4.2 at (-266, 276) | 2, 14, 4 |
| 4.3 El Ascensor de Esporas | B | grip near 4.3 at (-243, 277); grip near 4.2 at (-255, 264); grip near 4.3 at (-241, 277) | 2, 16, 4 |
| 4.4 Rebote Doble | B | grip near 4.4 at (-235, 295); grip near 4.4 at (-229, 292); grip near 4.4 at (-233, 295) | 2, 5, 4 |
| 4.5 La Baba | B | grip near 4.2 at (-255, 264); grip near 4.5 at (-227, 313) | 49, 2 |
| 4.6 El Hongo Gigante | B | grip near 4.6 at (-231, 333); grip near 4.6 at (-226, 336) | 2, 0 |
| 4.7 Trampolín en Cadena | B | grip near 4.7 at (-234, 345); grip near 4.7 at (-229, 345); grip near 4.7 at (-232, 346) | 3, 3, 1 |
| 4.8 Puente de Micelio | B | grip near 4.8 at (-248, 361); grip near 4.8 at (-243, 361); grip near 4.8 at (-246, 361) | 2, 2, 4 |
| 4.9 Los Ojos | A | grip near 4.2 at (-267, 276); grip near 4.9 at (-261, 361); grip near 4.9 at (-264, 361) | 87, 2, 1 |
| 4.10 El Salto del Pozo II | P | grip near 4.10 at (-292, 370); grip near 4.10 at (-284, 364); grip near 4.10 at (-289, 370) | 2, 9, 4 |
| 5.1 La Puerta | S | grip near 5.1 at (-314, 366); grip near 5.1 at (-309, 366); grip near 5.1 at (-312, 366) | 2, 2, 4 |
| 5.2 La Máscara | B | grip near 5.2 at (-352, 381); grip near 5.2 at (-346, 378); grip near 5.2 at (-349, 381) | 2, 5, 4 |
| 5.3 Los Pistones | B | grip near 5.3 at (-367, 400); grip near 5.3 at (-362, 396); grip near 5.3 at (-365, 396) | 0, 2, 1 |
| 5.4 Engranajes | B | grip near 5.4 at (-360, 412); grip near 5.4 at (-360, 412); grip near 5.4 at (-360, 412) | 1, 1, 4 |
| 5.5 El Salón de los Campeones | A | grip near 5.5 at (-366, 430); grip near 5.5 at (-363, 430); grip near 5.5 at (-363, 430) | 2, 1, 4 |
| 5.6 Incensarios | A | grip near 5.6 at (-333, 440); grip near 5.6 at (-328, 440); grip near 5.6 at (-331, 441) | 2, 3, 4 |
| 5.7 El Contrapeso | B | grip near 5.5 at (-352, 430); grip near 5.7 at (-348, 453); grip near 5.7 at (-350, 453) | 25, 2, 4 |
| 5.8 La Serpiente | B | grip near 5.8 at (-365, 460); grip near 5.8 at (-362, 460); grip near 5.8 at (-365, 460) | 1, 2, 4 |
| 5.9 Bloques Fantasma | B | grip near 5.7 at (-344, 453); grip near 5.9 at (-339, 463); grip near 5.9 at (-342, 462) | 11, 1, 1 |
| 5.10 El Altar | B | grip near 5.10 at (-328, 469); grip near 5.10 at (-323, 469); grip near 5.10 at (-326, 469) | 2, 2, 1 |
| 5.11 El Sacrificio | P | grip near 5.11 at (-309, 480); grip near 5.11 at (-304, 482); grip near 5.11 at (-307, 480) | 2, 0, 1 |
| 6.1 Primer Vapor | S | grip near 6.1 at (-283, 479); grip near 6.1 at (-278, 479); grip near 6.1 at (-281, 479) | 2, 2, 4 |
| 6.2 Piedra Caliente | A | grip near 6.2 at (-279, 486); grip near 6.2 at (-274, 488); grip near 6.2 at (-277, 486) | 2, 0, 4 |
| 6.3 Géiseres Gemelos | A | grip near 6.3 at (-272, 496); grip near 6.3 at (-267, 496); grip near 6.3 at (-270, 496) | 2, 2, 4 |
| 6.4 El Fuelle | A | grip near 6.4 at (-268, 514); grip near 6.4 at (-263, 512); grip near 6.4 at (-266, 512) | 0, 2, 4 |
| 6.5 Escoria | A | grip near 6.5 at (-285, 525); grip near 6.5 at (-280, 525); grip near 6.5 at (-282, 525) | 2, 2, 4 |
| 6.6 La Fragua | A | grip near 6.3 at (-266, 496); grip near 6.6 at (-255, 523); grip near 6.6 at (-257, 523) | 29, 2, 4 |
| 6.7 Tiro de Chimenea | A | grip near 6.3 at (-236, 479); grip near 6.7 at (-239, 535); grip near 6.7 at (-241, 536) | 59, 2, 1 |
| 6.8 El Último Aliento | A | grip near 6.8 at (-244, 549); grip near 6.8 at (-239, 549); grip near 6.8 at (-242, 549) | 2, 2, 4 |
| 6.9 La Luz | B | grip near 6.9 at (-247, 574); grip near 6.9 at (-242, 574); grip near 6.9 at (-245, 572) | 1, 1, 4 |
| 7.1 El Balcón | S | grip near 7.1 at (-230, 578); grip near 7.1 at (-225, 578); grip near 7.1 at (-228, 578) | 2, 2, 4 |
| 7.2 Nidos | A | grip near 7.2 at (-208, 590); grip near 7.2 at (-208, 590); grip near 7.2 at (-208, 590) | 1, 1, 1 |
| 7.3 Árbol Seco | A | grip near 7.3 at (-237, 600); grip near 7.3 at (-240, 604) | 2, 0 |
| 7.4 Puente Roto | A | grip near 7.4 at (-224, 623); grip near 7.4 at (-219, 624); grip near 7.4 at (-221, 624) | 3, 2, 1 |
| 7.5 La Cornisa | X | grip near 7.5 at (-209, 624); grip near 7.5 at (-207, 624); grip near 7.5 at (-207, 624) | 2, 1, 1 |
| 7.6 Desprendimiento | A | grip near 7.6 at (-208, 638); grip near 7.6 at (-202, 636); grip near 7.6 at (-205, 637) | 1, 3, 4 |
| 7.7 Los Burros | A | grip near 7.7 at (-247, 649); grip near 7.7 at (-242, 647); grip near 7.7 at (-245, 648) | 1, 3, 4 |
| 7.8 Viento a Favor | X | grip near 7.8 at (-209, 654); grip near 7.8 at (-204, 654); grip near 7.8 at (-207, 654) | 2, 2, 4 |
| 7.9 Chimenea de Roca | B | grip near 7.8 at (-207, 654); grip near 7.9 at (-202, 664); grip near 7.9 at (-204, 664) | 12, 2, 1 |
| 7.10 La Estación Baja | B | grip near 7.10 at (-211, 672); grip near 7.8 at (-206, 654); grip near 7.10 at (-209, 672) | 2, 20, 4 |
| 8.1 Abordar | A | grip near 8.1 at (-241, 688); grip near 8.1 at (-236, 688); grip near 8.1 at (-238, 689) | 3, 3, 4 |
| 8.2 De Góndola a Góndola | X | grip near 8.2 at (-230, 693); grip near 8.2 at (-225, 694); grip near 8.2 at (-228, 702) | 11, 10, 4 |
| 8.3 El Cable | X | grip near 8.3 at (-208, 698); grip near 8.3 at (-203, 701); grip near 8.3 at (-205, 700) | 4, 1, 4 |
| 8.4 El Pilón | X | grip near 8.4 at (-197, 704); grip near 8.4 at (-192, 703); grip near 8.4 at (-194, 707) | 1, 2, 0 |
| 8.5 Sillas Voladoras | X | grip near 8.5 at (-192, 714); grip near 8.5 at (-192, 714); grip near 8.5 at (-192, 714) | 1, 1, 1 |
| 8.6 El Colmillo | X |  |  |
| 8.7 Tirolesa | X | grip near 8.7 at (-167, 724); grip near 0.3 at (-32, 2); grip near 8.7 at (-165, 725) | 4, 725, 4 |
| 8.8 Contrapesos | X | grip near 8.8 at (-195, 720); grip near 8.8 at (-190, 720); grip near 8.8 at (-193, 720) | 2, 2, 4 |
| 8.9 La Góndola Rota | X | grip near 8.9 at (-206, 749); grip near 8.9 at (-201, 741); grip near 8.9 at (-203, 749) | 2, 10, 4 |
| 8.10 Vía Rápida | X | grip near 7.10 at (-222, 678); grip near 8.2 at (-228, 702) | 71, 48 |
| 8.11 La Estación Alta | X | grip near 8.11 at (-271, 786); grip near 8.11 at (-268, 786); grip near 8.11 at (-268, 786) | 2, 1, 4 |
| 9.1 Hielo Azul | B | grip near 9.1 at (-306, 786); grip near 9.1 at (-304, 786); grip near 9.1 at (-306, 786) | 1, 2, 4 |
| 9.2 Carámbanos | B | grip near 9.2 at (-328, 798); grip near 9.2 at (-328, 798); grip near 9.2 at (-328, 798) | 1, 1, 1 |
| 9.3 Puente de Nieve | B | grip near 9.3 at (-322, 804); grip near 9.3 at (-317, 804); grip near 9.3 at (-320, 804) | 2, 2, 4 |
| 9.4 La Cueva de Hielo | S | grip near 9.4 at (-303, 806); grip near 9.4 at (-298, 804); grip near 9.4 at (-300, 804) | 0, 2, 4 |
| 9.5 El Serac | B | grip near 9.5 at (-328, 831); grip near 9.5 at (-326, 832); grip near 9.5 at (-326, 832) | 3, 1, 4 |
| 9.6 Tobogán Helado | B | grip near 9.3 at (-321, 812); grip near 9.4 at (-290, 804); grip near 9.6 at (-311, 834) | 25, 33, 4 |
| 9.7 Ventisca | X | grip near 9.7 at (-285, 830); grip near 9.7 at (-283, 830); grip near 9.7 at (-283, 830) | 2, 1, 1 |
| 9.8 La Avalancha | X | grip near 9.8 at (-284, 846); grip near 9.7 at (-281, 836); grip near 9.8 at (-284, 846) | 1, 12, 1 |
| 9.9 Cornisa de Hielo | X | grip near 9.9 at (-286, 860); grip near 9.9 at (-285, 868); grip near 9.9 at (-285, 868) | 10, 1, 1 |
| 9.10 El Rimaye | X | grip near 9.9 at (-287, 861); grip near 9.10 at (-294, 873); grip near 9.10 at (-294, 873) | 15, 1, 1 |
| 10.1 El Filo | X | grip near 10.1 at (-306, 886); grip near 10.1 at (-304, 886); grip near 10.1 at (-304, 886) | 2, 1, 4 |
| 10.2 Banderas | X | grip near 10.2 at (-299, 904); grip near 8.1 at (-242, 688) | 0, 217 |
| 10.3 El Rayo | X | grip near 10.3 at (-311, 915); grip near 10.3 at (-306, 913); grip near 10.3 at (-308, 917) | 1, 3, 0 |
| 10.4 Veleta | X | grip near 10.4 at (-311, 921); grip near 10.4 at (-306, 929); grip near 10.4 at (-309, 925) | 6, 0, 4 |
| 10.5 El Papalote | X | grip near 10.5 at (-289, 933); grip near 10.5 at (-289, 933); grip near 10.5 at (-289, 936) | 1, 1, 0 |
| 10.6 Gendarmes | X | grip near 10.6 at (-288, 939); grip near 8.1 at (-239, 689); grip near 10.6 at (-286, 943) | 6, 257, 4 |
| 10.7 La Nube | X | grip near 10.7 at (-326, 946); grip near 10.1 at (-297, 890); grip near 10.7 at (-326, 947) | 0, 57, 1 |
| 10.8 El Globo | X | grip near 10.7 at (-325, 947); grip near 10.1 at (-297, 890); grip near 10.8 at (-322, 952) | 7, 64, 4 |
| 10.9 Escalera al Cielo | X | grip near 10.9 at (-330, 955); grip near 10.8 at (-324, 950); grip near 10.9 at (-330, 955) | 1, 7, 4 |
| 11.1 Sobre las Nubes | X | grip near 11.1 at (-346, 965); grip near 11.1 at (-341, 964); grip near 11.1 at (-344, 964) | 2, 2, 1 |
| 11.2 La Corona | X | grip near 11.2 at (-335, 964); grip near 11.2 at (-330, 965); grip near 11.2 at (-333, 964) | 2, 1, 1 |
| 11.3 Las Cuerdas del Campeón | X | grip near 10.8 at (-323, 951); grip near 10.1 at (-297, 890); grip near 11.3 at (-321, 982) | 30, 92, 1 |
| 11.4 El Último Salto | X | grip near 11.4 at (-332, 995); grip near 11.3 at (-322, 979); grip near 11.4 at (-330, 995) | 2, 18, 4 |
| 11.5 La Campana | X | grip near 11.5 at (-357, 999); grip near 10.8 at (-322, 960); grip near 11.5 at (-357, 999) | 1, 41, 3 |
| 11.6 Top Dog |  | grip near 11.6 at (-358, 1006); grip near 10.8 at (-322, 960); grip near 11.6 at (-356, 1006) | 2, 48, 4 |

**Totals:** 321 bodies, 0 pockets (softlocks), 0 lost from the world, 0 still moving after 150 s.
