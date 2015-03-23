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
print"Informations";
print <NAVIGATION>;
print"
<div class='container'>

	<div class='col-xs-6 col-sm-6 col-md-6'>
		<img src='img/mongodb.png' class='img-rounded' width='80%' height='80%'>
		<img src='img/bootstrap.png' class='img-rounded' width='100%' height='100%'>
		<img src='img/perl.jpg' class='img-rounded' width='100%' height='100%'>
	</div>
	<blockquote>
	<div class='col-xs-6 col-sm-6 col-md-6'>
		<h1><small>Présentation</small></h1>
		Un moteur de recherche basé sur les termes des
		documents, elle est disponible dans le premier onglet. Le deuxième onglet permet
		de faire une requête sur les métadonnées des documents. Le troisième onglet
		contient des statistiques descriptives sur les documents et les termes de la base
		de données. Il est possible de modifier des paramètres dans le quatrième onglet.

	<h1><small>Fonctionnement</small></h1>
	Chaque page du site est générée par un script écrit en Perl. Grâce à un driver
	le serveur communique avec MongoDB, une base de données noSQL qui stocke les
	données sous format JSON. Le bootstrap de Twitter est utilisée comme template pour
	le côté graphique du site.

	<h1><small>Colophon</small></h1>
	Ce site a été entièrement imaginé et réalisé par Salima Azzou, Kafil El Khadir, Rémi Simon et Max Halford.
	Tout le code du projet est disponible <a href='https://github.com/MaxHalford/Wikisid'>ici</a>.
<div>

</blockquote>
</div>
";
print "</body> </html>";
