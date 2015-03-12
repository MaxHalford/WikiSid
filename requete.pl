#!/opt/lampp/bin/perl -w

use strict;
use MongoDB;
use Lingua::Stem qw(stem);
use Data::Dumper;

#########################
### Connexion MongoDB ###
#########################

# On se connecte à la base de données
my $db = MongoDB::MongoClient -> new -> get_database('Wikinews');
# On récupère les indexs
my $inverse = $db -> get_collection('Index inverse');
my $direct = $db -> get_collection('Index direct');

###############
### Requête ###
###############

my @motsVides = separer(lireTexte('stockage/motsVides'));
# On récupère les données du formulaire de la page HTML
my %formulaire = ();
foreach my $element (split(/&/, $ENV{'QUERY_STRING'})){
	my ($variable, $valeur) = split(/=/, $element);
	$valeur =~ s/\+/ /g;
	$valeur =~ s/%(..)/pack('c',hex($1))/eg;
	$formulaire{$variable} = $valeur;
}
my $requete = $formulaire{'requete'};
# On la nettoie exactement comme les bodys auparavant
chomp $requete;
my @termes = preparer($requete);

# On va stocker les RSV dans un hashage
my %pertinences = RSV(@termes);

######################
### Affichage HTML ###
######################

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
print"<div align='center' class='container'>
<div id='accordeon' class='panel-group col-lg-12'>";
my $itemCounter = 1;
for my $document (keys %pertinences) {
	open FILE, '<', 'stockage/bodies/'.$document.'.txt' or die $!;
	my @contenu = <FILE>;
	my $body = $contenu[0];
	open(my $contenu, "<", );
	my $item = 'item'.$itemCounter;
	print"
	<div class='panel panel-info'>
		<div align='left' class='panel-heading'> 
		<h4>
			<a href='#$item' data-parent='#accordeon' data-toggle='collapse'>
				<font face='verdana'>$itemCounter. $document</font></a> 
      		</h4>
      		</div>
      		<div id='$item' class='panel-collapse collapse'>
        		<div align='left' class='panel-body'>$body</div>
      		</div>
    	</div>";
$itemCounter += 1;
}
print "</div> </div> </body> </html>";

#############################
### Fonctions de requêtes ###
#############################

sub preparer {
	# Paramètres
	my $mots = $_[0];
	$mots = minuscules($mots);
	$mots = ponctuation($mots);
	foreach my $mot (@motsVides) {
		$mots =~ s/\b$mot\b/ /gi;
		$mots =~ s/\s+/ /g;
	}
	my @mots = lemmatisation($mots);
	return @mots;
}

sub afficher {
	# Paramètres
	my (%hash) = @_;
	# print Dumper(\%hash);
	foreach my $key (sort { $hash{$b} <=> $hash{$a} } keys %hash) {
		printf "%-60s %s\n", $key;
	}
}

##############################
### Fonctions d'indexation ###
##############################

sub lireTexte {

	# Paramètres
	my ($chemin) = $_[0];
	# On ouvre le fichier
	open FILE, "<", $chemin or die $!;
	my @contenu = <FILE>;
	return $contenu[0];
}

sub minuscules {
	# Paramètres
	my ($texte) = $_[0];
	# On applique une expression régulière
	$texte =~ s/(.+)/\L$1/gi;
	return $texte;
}

sub ponctuation {

	# Paramètres
	my $texte = $_[0];

	# On applique une expression régulière
	$texte =~ s/([[:punct:]])/ /gi;
	$texte =~ s/\s+/ /g;
	return $texte;
}

sub separer {

	# Paramètres
	my $texte = $_[0];

	# On parcourt chaque mot vide
	my @mots = split( ' ', $texte );
	return @mots;
}

sub lemmatisation {

	# Paramètres
	my ($mots) = $_[0];
	
	# On lemmatise chaque mot
	my $stemmer = Lingua::Stem -> new(-locale => 'FR');
	$stemmer -> stem_caching({-level => 2 });
    $mots = $stemmer -> stem(separer($mots));
    # Attention, le stemmer renvoir un pointeur vers une liste
	return @$mots;
}

sub frequence {

	# Paramètres
	my (@mots) = @_;

	# Hash
	my %occurrences = ();

	#On vérifie chaque mot
	foreach my $mot (@mots) {

	 #S'il a déjà été rentré alors on incrémente l'entrée du dictionnaire
		if ( exists $occurrences{$mot} ) {
			$occurrences{$mot}++;

			#Sinon on crée une entrée dans le dictionnaire
		}
		else {
			$occurrences{$mot} = 1;
		}
	}
	return %occurrences;
}

sub lister {
	# Paramètres
	my $chemin = $_[0];
	# On ouvre le dossier
	opendir (DIR, $chemin) or die $!;
	my @fichiers = ();
	# On regarde chaque fichier
	while (my $fichier = readdir(DIR)){
		# On vérfie que le fichier soit un fichier html
		if ($fichier =~ /.*\.txt/) {
			# On l'ajoute à la liste des fichiers
			push(@fichiers, $chemin.$fichier);
		}
	}
	return @fichiers;
}

############################
### Fonctions de scoring ###
############################

sub RSV {
	# Paramètres
	my (@termes) = @_;
	# On garde en mémoire le nombre de documents
	my $N = $direct -> count;
	# On va stocker les RSV dans un hashage
	my %pertinences = ();
	# On regarde chaque terme
	foreach my $terme (@termes) {
		# On fait une requête pour le terme
		my $curseur = $inverse -> find({'_id' => $terme});
		# On vérifie que le terme est dans la BDD
		if ($curseur -> count eq 1) {
			# On récupère le résultat
			my $info = $curseur -> next;
			# On extrait le DF
			my $DF = $info -> {'nbDocuments'};
			# On calculte l'IDF
			my $IDF = log($N / 1 + $DF);
			# On extrait les documents qui contiennent le terme
			my $pointeurHash = $info -> {'documents'};
			my %docs = %$pointeurHash;
			# Pour chaque document contenant le terme
			foreach my $doc (keys %docs) {
				# On extrait le TF
				my $TF = $docs{$doc};
				# On calcule le TFIDF
				my $TFIDF = $TF * $IDF;
				# On augmente la pertinence du document (le RSV)
				$pertinences{$doc} += $TFIDF;
			}
		}
	}
	# 
	return %pertinences;	
}
