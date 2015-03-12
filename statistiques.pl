#!/opt/lampp/bin/perl -w

use strict;
use MongoDB;
use Digest::MD5;

# Header
open(HEADER, '<', 'html/header');
# Onglets de navigation
open(NAVIGATION, '<', 'html/navigation');
# Barre de recherche
open(RECHERCHE, '<', 'html/recherche');
# Affichage
print "content-type : text/html\n\n <!DOCTYPE html>";
print <HEADER>;
print"Statistiques";
print <NAVIGATION>;

# On se connecte à la base de données 
my $db = MongoDB::MongoClient -> new -> get_database('Wikinews');
# On se connecte à l'index direct
my $direct = $db -> get_collection('Index direct');
# On se connecte à l'index inverse
my $inverse = $db -> get_collection('Index inverse');
# On fait en sorte que MongoDB renvoit des caractères UTF-8 décodés
$MongoDB::BSON::utf8_flag_on = 0;

####################################
### Les documents les plus longs ###
####################################

#~ my @documents = ();
#~ # d documents
#~ my $d = 10;
#~ # Requête des d plus documents les plus longs
#~ my $curseurDocs = $direct -> find({}) -> sort({'longueur' => -1}) -> limit($d);
#~ # On extrait le nom et la longueur de chaque document
#~ while (my $pointeur = $curseurDocs -> next) {
	#~ my %document = %$pointeur;
	#~ my $value = $document{'longueur'};
	#~ # On génère une couleur aléatoire
	#~ my $randomHex = join "", map {unpack "H*", chr(rand(256))} 1..3;
	#~ my $color = "#$randomHex";
	#~ my $highlight = '#FF5A5E';
	#~ my $label = $document{'_id'};
	#~ $label =~ s/'/ /g;
	#~ push(@documents, "{value: $value, color: '$color', highlight: '$highlight', label: '$label'}");
#~ }
#~ # On créé le format que lit Javascript (une liste de hashages)
#~ my $pieData = join(', ', @documents);
#~ print"
#~ <div align='center' class='container'>
	#~ <h2><font face='verdana'>Les documents les plus longs</font></h2>
	#~ </br>
	#~ <div style='width: 50%'>
		#~ <canvas id='pie' height='450' width='600'></canvas>
	#~ </div>
	#~ <script>
		#~ var pieData = [$pieData];
		#~ window.onload = function(){
			#~ var ctx = document.getElementById('pie').getContext('2d');
			#~ window.myPie = new Chart(ctx).Pie(pieData);
		#~ };
	#~ </script>
#~ </div>";

####################################
### Les lemmes les plus utilisés ###
####################################

my $lemmes;
my $frequences;
# l lemmes
my $l = 50;
# Requête des l lemmes les plus utilisés
my $curseurLemmes = $inverse -> find({}) -> sort({'ndDocuments' => -1}) -> limit($l);
# On extrait le nom et la longueur de chaque document
while (my $pointeur = $curseurLemmes -> next) {
	my %lemme = %$pointeur;
	my $label = $lemme{'_id'};
	my $value = $lemme{'nbDocuments'};
	$lemmes .= "'$label',";
	$frequences .= "$value,";
}
print"
<div align='center' class='container'>
	<div style='width: 100%'>
		<canvas id='bar' height='450' width='600'></canvas>
	</div>
	<script>
	var randomScalingFactor = function(){ return Math.round(Math.random()*100)};
	var barChartData = {
		labels : [$lemmes],
		datasets : [
			{
				fillColor : 'rgba(151,187,205,0.5)',
				strokeColor : 'rgba(151,187,205,0.8)',
				highlightFill : 'rgba(151,187,205,0.75)',
				highlightStroke : 'rgba(151,187,205,1)',
				data : [$frequences]
			}
		]

	}
	window.onload = function(){
		var ctx = document.getElementById('bar').getContext('2d');
		window.myBar = new Chart(ctx).Bar(barChartData, {
			responsive : true
		});
	}

	</script>
</div>";
print"
</body>
</html>
";
