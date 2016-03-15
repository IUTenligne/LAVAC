unit XPMs;

interface

const

  XPMFileNew : array [0..16] of string = (
      '11 13 3 1',
      '. c None',
      'x c #000000',  // black
      'o c #FFFFFF',  // white
      'xxxxxxxx...',
      'xooooooxx..',
      'xooooooxox.',
      'xooooooxxxx',
      'xooooooooox',
      'xooooooooox',
      'xooooooooox',
      'xooooooooox',
      'xooooooooox',
      'xooooooooox',
      'xooooooooox',
      'xooooooooox',
      'xxxxxxxxxxx');

  XPMFileOpen : array [0..17] of string = (
      '16 13 4 1',
      '. c None',     // no color
      '# c #000000',  // black
      'y c #ffff00',  // yellow
      'g c #AFAF00',  // grayed yellow
      '.......#####....',
      '............#.#.',
      '.............##.',
      '.####.......###.',
      '#yyyy######.....',
      '#yyyyyyyyy#.....',
      '#yyyyyyyyy#.....',
      '#yyyy###########',
      '#yyy#ggggggggg#.',
      '#yy#ggggggggg#..',
      '#y#ggggggggg#...',
      '##ggggggggg#....',
      '###########.....');

  XPMFileSave : array [0..17] of string = (
      '14 14 4 1',
      '. c None',     // no color
      '# c #000000',  // black
      'g c #AFAF00',  // grayed yellow
      '* c #C0C0C0',  // light gray
      '##############',
      '#g#********#*#',
      '#g#********###',
      '#g#********#g#',
      '#g#********#g#',
      '#g#********#g#',
      '#gg#########g#',
      '#gggggggggggg#',
      '#gg#########g#',
      '#gg#######*#g#',
      '#gg#######*#g#',
      '#gg#######*#g#',
      '.#############');

  XPMEditAdd : array [0..16] of string = (
          '15 13 3 1',
          '. c None',      // None
          'o c #000000',   // Black
          '- c #FFFFFF',   // White
          '...............',
          '...oooooo......',
          '...o----oo.....',
          '...o----o-o....',
          '...o----oooo...',
          '...o-------o...',
          '...o-------o...',
          '...o-------o...',
          '...o-------o...',
          '...o-------o...',
          '...ooooooooo...',
          '...............',
          '...............');

  XPMEditCopy : array [0..17] of string = (
          '15 13 4 1',
          '. c None',      // None
          '# c #000000',   // Black
          '- c #FFFFFF',   // White
          'o c #0000FF',   // Blue
          '######.........',
          '#----##........',
          '#----#-#.......',
          '#-##-#oooooo...',
          '#-----o----oo..',
          '#-####o----o-o.',
          '#-----o-##-oooo',
          '#-####o-------o',
          '#-----o-#####-o',
          '######o-------o',
          '......o-#####-o',
          '......o-------o',
          '......ooooooooo');

  XPMEditDelete : array [0..17] of string = (
          '14 13 4 1',
          '. c None',      // None
          '# c #000000',   // Black
          '- c #FFFFFF',   // White
          'r c #FF0000',   // Red
          'rr-........rr-',
          'rrrr-####.rr-.',
          '.rrrr----rr-..',
          '...rrr--rr-...',
          '...#rrrrr--#..',
          '...#-rrr---#..',
          '...#rrrrr--#..',
          '...rrr--rr-#..',
          '..rrr----rr-..',
          '.rrr------r-..',
          '.rrr-######r-.',
          '..r-..........',
          '............r-');

  XPMEditUp : array [0..15] of string = (
          '7 13 2 1',
          '. c None',
          'x c #000000',
          '...x...',
          '...x...',
          '..xxx..',
          '..xxx..',
          '.xxxxx.',
          '.xxxxx.',
          'xxxxxxx',
          'xxxxxxx',
          '..xxx..',
          '..xxx..',
          '..xxx..',
          '..xxx..',
          '..xxx..');
  XPMEditDown : array [0..15] of string = (
          '7 13 2 1',
          '. c None',
          'x c #000000',
          '..xxx..',
          '..xxx..',
          '..xxx..',
          '..xxx..',
          '..xxx..',
          'xxxxxxx',
          'xxxxxxx',
          '.xxxxx.',
          '.xxxxx.',
          '..xxx..',
          '..xxx..',
          '...x...',
          '...x...');

  XPMGenerate : array [0..24] of string = (
          '15 17 7 1',
          '. c None',      // None
          '# c #000000',   // Black
          '- c #FFFFFF',   // White
          'x c #808080',   // Dark Gray
          'r c #800000',   // Dark Red
          '* c #C0C0C0',   // Light Gray
          'y c #FFFF00',   // Yellow
          '.....xxxxx.....',
          '.xxx#-****#xxx.',
          'x---#######---#',
          'x-------------#',
          'x--------###--#',
          'x--------#rr#-#',
          'x-------#y##--#',
          'x-------#yx#--#',
          'x------#y*#---#',
          'x------#yx#---#',
          'x-----#y*#----#',
          'x-----#yx#----#',
          'x-----###-----#',
          'x-----##------#',
          'x-#-#-#-------#',
          'x-------------#',
          '.#############.');

  XPMPropField : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #0000FF',  // color blue
      '...............',
      '...............',
      '...............',
      '..+++++++++++..',
      '..+.........+..',
      '..+.........+..',
      '..+.........+..',
      '..+.........+..',
      '..+.........+..',
      '..+.........+..',
      '..+.........+..',
      '..+++++++++++..',
      '...............',
      '...............',
      '...............');

  XPMPropProperty : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #0000FF',  // color blue
      '...............',
      '.+++++++++++++.',
      '.+...........+.',
      '.+...........+.',
      '.+...+**.....+.',
      '.+.....+*....+.',
      '.+.+*+*++**..+.',
      '.+.++++++++*.+.',
      '.+.+*+*++**..+.',
      '.+.....+*....+.',
      '.+...+**.....+.',
      '.+...........+.',
      '.+...........+.',
      '.+++++++++++++.',
      '...............');

  XPMPropFunction : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #00FF00',  // color green
      '...............',
      '...............',
      '...............',
      '..***..........',
      '...++**........',
      '.....++*.......',
      '+*+*+*++**..*+*',
      '++++++++++*.+++',
      '+*+*+*++**..*+*',
      '.....++*.......',
      '...++**........',
      '..***..........',
      '...............',
      '...............',
      '...............');

  XPMPropProcedure : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #00FF00',  // color green
      '...............',
      '...............',
      '...............',
      '....***........',
      '.....++**......',
      '.......++*.....',
      '+*+*+*+*++**...',
      '++++++++++++*..',
      '+*+*+*+*++**...',
      '.......++*.....',
      '.....++**......',
      '....***........',
      '...............',
      '...............',
      '...............');

  XPMPropHelperProc : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #FFFF00',  // color yellow
      '...............',
      '...............',
      '...............',
      '....***........',
      '.....++**......',
      '.......++*.....',
      '+*+*+*+*++**...',
      '++++++++++++*..',
      '+*+*+*+*++**...',
      '.......++*.....',
      '.....++**......',
      '....***........',
      '...............',
      '...............',
      '...............');

  XPMPropHelperFunc : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #FFFF00',  // color yelow
      '...............',
      '...............',
      '...............',
      '..***..........',
      '...++**........',
      '.....++*.......',
      '+*+*+*++**..*+*',
      '++++++++++*.+++',
      '+*+*+*++**..*+*',
      '.....++*.......',
      '...++**........',
      '..***..........',
      '...............',
      '...............',
      '...............');

  XPMPropSignalType : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #0000FF',  // color blue
      '...............',
      '+++.........+++',
      '++...........++',
      '+.+.........+.+',
      '...+.......+...',
      '....+.....+....',
      '...............',
      '.......*.......',
      '...............',
      '....+.....+....',
      '...+.......+...',
      '+.+.........+.+',
      '++...........++',
      '+++.........+++',
      '...............');

  XPMPropSignal : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #0000FF',  // color blue
      '...............',
      '+++.........+++',
      '++...........++',
      '+.+.........+.+',
      '...+*******+...',
      '...*+.....+*...',
      '...*.+...+.*...',
      '...*...*...*...',
      '...*.+...+.*...',
      '...*+.....+*...',
      '...+*******+...',
      '+.+.........+.+',
      '++...........++',
      '+++.........+++',
      '...............');

  XPMPropdeclar : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #FFFFFF',  // white
      '+ c #FFFF00',  // color yelow
      '.......+.......',
      '......+++......',
      '.....+++++*....',
      '.....+++++*....',
      '.....+++++*....',
      '.....+++++*....',
      '......+++**....',
      '......+++*.....',
      '.......+**.....',
      '.......+*......',
      '......+++......',
      '.....+++++*....',
      '.....+++++*....',
      '......+++**....',
      '.......+**.....');

  XPMPropTypeDecl : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #FFFFFF',  // white
      '+ c #00FF00',  // color green
      '.......+.......',
      '......+++......',
      '.....+++++*....',
      '.....+++++*....',
      '.....+++++*....',
      '.....+++++*....',
      '......+++**....',
      '......+++*.....',
      '.......+**.....',
      '.......+*......',
      '......+++......',
      '.....+++++*....',
      '.....+++++*....',
      '......+++**....',
      '.......+**.....');

  XPMPropConstr : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #0000FF',  // color blue
      '...............',
      '...............',
      '...............',
      '..***.....++++*',
      '...++**...+++++',
      '.....++*.....+*',
      '+*+*+*++**...++',
      '++++++++++*..+*',
      '+*+*+*++**...++',
      '.....++*.....+*',
      '...++**...+++++',
      '..***.....*+*+*',
      '...............',
      '...............',
      '...............');

  XPMPropDestr : array [0..19] of string = (
      '15 15 4 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #0000FF',  // color blue
      '- c #FF0000',  // color red
      '............-..',
      '...........--..',
      '..........--...',
      '......***--....',
      '.......+--*....',
      '.......--++*...',
      '+*+*+*--+*++**.',
      '+++++--+++++++*',
      '+*+*--+*+*++**.',
      '...--....++*...',
      '..--...++**....',
      '.--...***......',
      '--.............',
      '-..............',
      '...............');

  XPMPropInitial : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #0000FF',  // color blue
      '+*.............',
      '+*.............',
      '+*.............',
      '+*....***......',
      '+*.....++**....',
      '+*.......++*...',
      '+*+*+*+*+*++**.',
      '++++++++++++++*',
      '+*+*+*+*+*++**.',
      '+*.......++*...',
      '+*.....++**....',
      '+*....***......',
      '+*.............',
      '+*.............',
      '+*.............');

  XPMPropFinal : array [0..18] of string = (
      '15 15 3 1',
      '. c None',     // no color
      '* c #000000',  // black
      '+ c #0000FF',  // color blue
      '.............+*',
      '.............+*',
      '.............+*',
      '....***......+*',
      '.....++**....+*',
      '.......++*...+*',
      '+*+*+*+*++**.+*',
      '++++++++++++*+*',
      '+*+*+*+*++**.+*',
      '.......++*...+*',
      '.....++**....+*',
      '....***......+*',
      '.............+*',
      '.............+*',
      '.............+*');


implementation

end.
