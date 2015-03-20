#!/opt/lampp/bin/perl -w

use strict;

# Header
open(HEADER, '<', 'html/header');
# Onglets de navigation
open(NAVIGATION, '<', 'html/navigation');
# Barre de recherche
open(RECHERCHE, '<', 'html/recherche');
# Affichage
print "content-type : text/html\n\n <!DOCTYPE html>";
print <HEADER>;
print"Paramètres";
print <NAVIGATION>;
print"
<div class='btn-group'> 
  <button class='btn btn-primary dropdown-toggle' data-toggle='dropdown'>Selectionner une categorie <span class='caret'></span></button>
  <ul class='dropdown-menu'>
    <li><a href='#'>Categ1</a></li>
    <li><a href='#'>Categ2</a></li>
    <li><a href='#'>Categ3</a></li>
    <li><a href='#'>Categ4</a></li>
  </ul>
</div>";
print "</body> </html>";
