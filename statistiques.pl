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

my @couleurs = ("rgba(151,187,205,0.5)", "rgba(151,187,205,0.8)");
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
	<h2><font face='verdana'><small>Les documents les plus longs</small></font></h2>
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
my $l = 20;
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
	<h2><font face='verdana'><small>Les lemmes les plus présents</small></font></h2>
	<div style='width: 90%'>
		<canvas id='bar' height='300' width='400'></canvas>
	</div>
</div>
</br>";

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

# On ouvre le fichier blob
open FILE, '<', 'stockage/blob' or die $!;
# On met chaque ligne dans un tableau
my @blob = <FILE>;
# On raccorde les lignes
my $blob = join('', @blob);
# Et on enlève les retours chariots
$blob =~ s/\s+/ /g;

# Nettoyer

# Séparer le string en une liste de mots
my @motsBlob = split( ' ', $blob);
# Compter la fréquence de chaque mot
my %frequences = ();
foreach my $mot (@motsBlob) {
	if (exists $frequences{$mot}) {
		$frequences{$mot} ++;
	} else {
		$frequences{$mot} = 1;
	}
}
# On prend les meilleurs
my $array = '';
my $compteur = 1;
foreach my $key (sort {$frequences{$b} <=> $frequences{$a}} keys %frequences) {
	if ($compteur < 30) {
		$array .= "'$key',";
	}
	$compteur ++;
}

print"
<script src='js/d3-cloud/lib/d3/d3.js'></script>
<script src='js/d3-cloud/d3.layout.cloud.js'></script>
<script>
  var fill = d3.scale.category20();

  d3.layout.cloud().size([300, 300])
      .words([$array].map(function(d) {
        return {text: d, size: 30 + Math.random() * 60};
      }))
      .padding(5)
      .rotate(function() { return ~~(Math.random() * 2) * 90; })
      .font('Impact')
      .fontSize(function(d) { return d.size; })
      .on('end', draw)
      .start();

  function draw(words) {
    d3.select('body').append('svg')
        .attr('width', 300)
        .attr('height', 300)
      .append('g')
        .attr('transform', 'translate(150,150)')
      .selectAll('text')
        .data(words)
      .enter().append('text')
        .style('font-size', function(d) { return d.size + 'px'; })
        .style('font-family', 'Impact')
        .style('fill', function(d, i) { return fill(i); })
        .attr('text-anchor', 'middle')
        .attr('transform', function(d) {
          return 'translate(' + [d.x, d.y] + ')rotate(' + d.rotate + ')';
        })
        .text(function(d) { return d.text; });
  }
</script>
";

print"
</body>
</html>
";
	
