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
print"Moteur de recherche";
print <NAVIGATION>;
print <RECHERCHE>;
print "</body> </html>";
