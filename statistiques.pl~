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

my @couleurs = ("#2aabd2", "#E0E0E0");
my @documents = ();
# d documents
my $d = 20;
# Requête des d plus documents les plus longs
my $curseurDocs = $direct -> find({}) -> sort({'longueur' => -1}) -> limit($d);
# La couleur change
my $compteurCouleur = 0;
# On extrait le nom et la longueur de chaque document
while (my $pointeur = $curseurDocs -> next) {
	my %document = %$pointeur;
	my $value = $document{'longueur'};
	my $color = $couleurs[$compteurCouleur % 2];
	$compteurCouleur ++;
	my $highlight = '#FF5A5E';
	my $label = $document{'_id'};
	$label =~ s/'/ /g;
	push(@documents, "{value: $value, color: '$color', highlight: '$highlight', label: '$label'}");
}
# On créé le format que lit Javascript (une liste de hashages)
my $pieData = join(', ', @documents);
print"
<div align='center' class='container'>
	<h2><font face='verdana'>Les documents les plus longs</font></h2>
	</br>
	<div style='width: 90%'>
		<canvas id='pie' height='300' width='400'></canvas>
	</div>
</div>
</br>";

####################################
### Les lemmes les plus utilisés ###
####################################

my $lemmes;
my $frequences;
# l lemmes
my $l = 30;
# Requête des l lemmes les plus utilisés
my $curseurLemmes = $inverse -> find({}) -> sort({'nbDocuments' => -1}) -> limit($l);
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
	<h2><font face='verdana'>Les lemmes les plus présents</font></h2>
	<div style='width: 90%'>
		<canvas id='bar' height='300' width='400'></canvas>
	</div>
</div>";

#################
### Affichage ###
#################

print"
<script>
	var pieData = [$pieData];

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
		var ctx = document.getElementById('pie').getContext('2d');
		window.myPie = new Chart(ctx).Pie(pieData);
			
		var ctx2 = document.getElementById('bar').getContext('2d');
		window.myBar = new Chart(ctx2).Bar(barChartData);
	};
</script>
";

#######################################
### Wordcloud de tous les documents ###
#######################################



print"
</body>
</html>
";

sub gradient {
    my ($min, $max) = @_;
    my $mean = ($min + $max) / 2;
    my $step = 255 / ($mean - $min);
    return sub {
        my $num = shift;
        return "FF0000" if $num <= $min;    # lower boundry
        return "00FF00" if $num >= $max;    # upper boundary
        if ($num < $mean) {
            return sprintf "FF%02X00" => int(($num - $min) * $step);
        }
        else {
            return
              sprintf "%02XFF00" => 255 - int(($num - $mean) * $step);
        }
    }
}
	
