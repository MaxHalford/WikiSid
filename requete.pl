#!/opt/lampp/bin/perl -w

use strict;
use MongoDB;
use Lingua::Stem qw(stem);
use Data::Dumper;
use Encode;
use Time::HiRes qw(time);
use List::Util qw(sum);
use List::Util qw(max);
#use open qw/:std :utf8/;
use JSON;

# On ouvre les paramètres définit par l'utilisateur
open my $json, '<', 'parametres.json' or die $!;
my $parametres = decode_json(<$json>);
my %parametres = %$parametres;

# On fait en sorte que MongoDB renvoit des caractères UTF-8 décodés
$MongoDB::BSON::utf8_flag_on = 0;

# On va mesurer le temps que prend la requête
my $t0 = time;

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
my @termes = lemmatisation(preparer($requete));

# On va stocker les RSV dans un hashage
my %pertinences;
# On utilise la méthode de scoring définit dans les paramètres
if ($parametres{'methode'} eq 'TFIDF') {
	%pertinences = TFIDF(@termes);
} else {
	if ($parametres{'methode'} eq 'TFIDF_Variete') {
		%pertinences = TFIDF_Variete(@termes);
	} else {
		if ($parametres{'methode'} eq 'Okapi_BM25') {
			%pertinences = BM25(@termes);
		} else {
			if ($parametres{'methode'} eq 'Frequentielle') {
			%pertinences = frequentielle(@termes);
			}
		}
	}
}

# On stocke les métadonnées, les notes et les commentaires chaque article
my %dates;
my %longueurs;
my %nbMots;
my %categories;
my %sources;
my %commentaires;
my %notes;
my %nbNotes;
foreach my $document (keys %pertinences) {
	my $curseur = $direct -> find({'_id' => qr/$document/});
	# On vérifie que le document existe bien
	if ($curseur -> count eq 1) {
		my $info = $curseur -> next;
		# Date de sortie du document
		$dates{$document} = $info -> {'dateEcriture'};
		# Longueur du document
		$longueurs{$document} = $info -> {'longueur'};
		# Nombre de mot du document
		$nbMots{$document} = $info -> {'nbMots'};
		# Catégories du document
		my $pointeurCategories = $info -> {'categories'};
		my @categories = @$pointeurCategories;
		foreach my $categorie (@categories) {
			$categories{$document} .= decode('UTF-8', "<p>$categorie</p>");
		}
		# Sources du document
		my $pointeurSources = $info -> {'sources'};
		my @sources = @$pointeurSources;
		foreach my $source (@sources) {
			$sources{$document} .= decode('UTF-8', "<p>$source</p>");
		}
		# Note moyenne du document
		my $pointeurNotes = $info -> {'notes'};
		my @notes = @$pointeurNotes;
		my $nbNotes = @notes;
		$nbNotes{$document} = "<p>$nbNotes</p>";
		# Attention à ne pas diviser par 0 grâce à "max"
		my $noteMoyenne = sum(@notes) / max(1, $nbNotes);
		$notes{$document} = decode('UTF-8', "<p>$noteMoyenne</p>");
		# Commentaires du document
		my $pointeurCommentaires = $info -> {'commentaires'};
		my @commentaires = @$pointeurCommentaires;
		foreach my $commentaire (@commentaires) {
			$commentaires{$document} .= decode('UTF-8', "<p>$commentaire</p>");
		}
	}
}

######################
### Affichage HTML ###
######################

# On va concatener tous les bodys
my $blob = '';
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
print"
<form align='center' class='form-inline well well-lg' action='./requete.pl' method='get'>
	<div class='form-group'>
		<label class='sr-only' for='text'>Saisie</label>
		<input name=requete id='text' size='35' type='text' class='form-control' placeholder=\'$requete\'>
		<button class='btn btn-info' type='submit'><span class='glyphicon glyphicon-search'></span> Rechercher</button>
	</div>
</form>";
print"
<div align='center' class='container'>
	<div id='accordeon' class='panel-group col-lg-12'>";
my $itemCounter = 1;
foreach my $document (keys %pertinences) {
	open FILE, '<:utf8', 'stockage/bodies/'.$document.'.txt' or die $!;
	my @contenu = <FILE>;
	my $body = $contenu[0];
	# On prépare les métadonnées à afficher dans une fenêtre modale
	my $dateEcriture = decode('UTF-8', "<p><h2>Date d'écriture</h2></p>").$dates{$document};
	my $longueur = decode('UTF-8', '<p><h2>Longueur</h2></p>').$longueurs{$document};
	my $nbMots = decode('UTF-8', '<p><h2>Nombre de mots différents</h2></p>').$nbMots{$document};
	my $categories = decode('UTF-8', '<p><h2>Catégories</h2></p>').$categories{$document};
	my $sources = decode('UTF-8', '<p><h2>Sources</h2></p>').$sources{$document};
	my $noteMoyenne = decode('UTF-8', '<p><h2>Note moyenne</h2></p>').$notes{$document};
	my $nbNotes = decode('UTF-8', '<p><h2>Nombre de notes</h2></p>').$nbNotes{$document};
	my $commentaires = decode('UTF-8', '<p><h2>Commentaires précédents</h2></p>').$commentaires{$document};
	# On a besoin de compter les document pour les classes HTML
	my $item = 'item'.$itemCounter;
	$document = decode('UTF-8', decode('UTF-8', encode('UTF-8', $document)));
	print"
	<div class='panel panel-info'>
		<div align='left' class='panel-heading'> 
			<h4><a href='#$item' data-parent='#accordeon' data-toggle='collapse'>$itemCounter. $document</a></h4>
      	</div>
		<div id='$item' class='panel-collapse collapse'>
        		<div align='left' class='panel-body'>
					$body
				</br>
				</br>
				<div class='pull-right'>
					<button data-toggle='modal' href='#noter$item' class='btn btn-success'>Noter</button>
					<div class='modal fade' id='noter$item'>
						  <div class='modal-dialog'>
								<div class='modal-content'>
										<div class='modal-header'>
											<button type='button' class='close' data-dismiss='modal'>x</button>
											<h4 class='modal-title'>$document</h4>
										</div>
									<div class='modal-body'>
									<form align='center' class='form-inline well well-lg' action='./noter.pl' method='get' accept-charset='UTF-8'>
										<div class='form-group'>
											<span class='rating'>
												<input type='hidden' name='document' value=\'$document\'>
												<input type='hidden' name='requete' value=\'$requete\'>
												<input type='radio' class='rating-input' id='rating-input-$item-5' name='rating' value=5>
												<label for='rating-input-$item-5' class='rating-star'></label>
												<input type='radio' class='rating-input' id='rating-input-$item-4' name='rating' value=4>
												<label for='rating-input-$item-4' class='rating-star'></label>
												<input type='radio' class='rating-input' id='rating-input-$item-3' name='rating' value=3>
												<label for='rating-input-$item-3' class='rating-star'></label>
												<input type='radio' class='rating-input' id='rating-input-$item-2' name='rating' value=2>
												<label for='rating-input-$item-2' class='rating-star'></label>
												<input type='radio' class='rating-input' id='rating-input-$item-1' name='rating' value=1>
												<label for='rating-input-$item-1' class='rating-star'></label>
											</span>
											<button class='btn btn-success' type='submit'>Valider</button>
										</div>
									</form>
									</div>
								</div>
						  </div>
					</div>
					<button data-toggle='modal' href='#commenter$item' class='btn btn-success'>Commenter</button>
					<div class='modal fade' id='commenter$item'>
						  <div class='modal-dialog'>
								<div class='modal-content'>
									<div class='modal-header'>
										<button type='button' class='close' data-dismiss='modal'>x</button>
										<h4 class='modal-title'>$document</h4>
									</div>
									<div class='modal-body'>
									<form align='center' class='form-inline well well-lg' action='./commenter.pl' method='get' accept-charset='UTF-8'>
										<div class='form-group'>
											<input type='hidden' name='document' value=\'$document\'>
											<input type='hidden' name='requete' value=\'$requete\'>
											<input name='commentaire' id='commentaire-input-$item' size='35' type='text' class='form-control'>
											<button class='btn btn-success' type='submit'>Valider</button>
										</div>
									</form>
									<h3><small>$commentaires</small></h3>
									</div>
								</div>
						</div>
					</div>
					<button data-toggle='modal' href='#info$item' class='btn btn-success'>Informations</button>
					<div class='modal fade' id='info$item'>
						  <div class='modal-dialog'>
								<div class='modal-content'>
										<div class='modal-header'>
											<button type='button' class='close' data-dismiss='modal'>x</button>
											<h4 class='modal-title'>$document</h4>
										</div>
										<div class='modal-body'>
											<h3><small>$dateEcriture</small></h3>
											<h3><small>$longueur</small></h3>
											<h3><small>$nbMots</small></h3>
											<h3><small>$sources</small></h3>
											<h3><small>$categories</small></h3>
											<h3><small>$noteMoyenne</small></h3>
											<h3><small>$nbNotes</small></h3>
										</div>
								</div>
						  </div>
					</div>
        		</div>
		</div>
    </div>
</div>
";
$itemCounter += 1;
}

print "</div> 
</div>
</br>"; 

my $elapsed = time - $t0;
print "<center><h1><small>Temps de réponse: $elapsed ms</small></h1></center>";

print"</br>
</body>
</html>";

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
	return $mots;
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
	return decode('UTF-8', $contenu[0]);
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

####################
### TFIDF simple ###
####################

sub TFIDF {
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
			# On calcule l'IDF
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
	return %pertinences;	
}

##########################################################
### TFIDF qui tient compte de la variété des documents ###
##########################################################

sub TFIDF_Variete {
	# Paramètres
	my (@termes) = @_;

	# On va calculer la variété des documents par rapport à la requête
	my %varietes = ();
	
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
			# On calcule l'IDF
			my $IDF = log($N / 1 + $DF);
			# On extrait les documents qui contiennent le terme
			my $pointeurHash = $info -> {'documents'};
			my %docs = %$pointeurHash;
			# Pour chaque document contenant le terme
			foreach my $doc (keys %docs) {

				# Le document contient un mot de la requête			
				$varietes{$doc} ++;
				
				# On extrait le TF
				my $TF = $docs{$doc};
				# On calcule le TFIDF
				my $TFIDF = $TF * $IDF;
				# On augmente la pertinence du document (le RSV)
				$pertinences{$doc} += $TFIDF;
			}
		}
	}

	# Pour chaque document trouvé
	foreach my $doc (keys %pertinences) {
		# On multiplie le TFIDF du document par sa variété
		$pertinences{$doc} *= $varietes{$doc}
	}

	return %pertinences;	
}

##################
### Okapi BM25 ###
##################

sub BM25 {
	# Paramètres
	my (@termes) = @_;
	# On garde en mémoire le nombre de documents
	my $N = $direct -> count;
	# On va stocker les RSV dans un hashage
	my %pertinences = ();
	# On regarde chaque terme
	foreach my $terme (@termes) {
		# Hyperparamètres
		my $b = 0.75;
		my $k = 1.6;
		# On fait une requête pour le terme
		my $curseur = $inverse -> find({'_id' => $terme});
		# On vérifie que le terme est dans la BDD
		if ($curseur -> count eq 1) {
			# On récupère le résultat
			my $info = $curseur -> next;
			# On extrait le DF
			my $DF = $info -> {'nbDocuments'};
			# On calcule l'IDF
			my $IDF = log($N - $DF + 0.5 / $DF + 0.5);
			# On extrait les documents qui contiennent le terme
			my $pointeurHash = $info -> {'documents'};
			my %docs = %$pointeurHash;
			# Il faut extraire la longueur de chaque document
			my %longueurDocuments = ();
			# Pour chaque document qui contient le terme
			foreach my $doc (keys %docs) {
				# On extrait la longueur du document
				my $curseur = $direct -> find({'_id' => qr/$doc/});
				if ($curseur -> count eq 1) {
					my $info = $curseur -> next;
					my $longueur = $info -> {'longueur'};
					$longueurDocuments{$doc} = $longueur;
				}
			}
			# On veut calculer la longueur moyenne des documents
			my $longueur = 0;
			# Pour chaque document
			foreach my $document (keys %longueurDocuments) {
				# On ajoute la longueur
				$longueur += $longueurDocuments{$document};
			}
			# On divise par le nombre de documents
			my $nbDocuments = keys %longueurDocuments;
			my $longueurMoyenne = $longueur / $nbDocuments;
			# Pour chaque document contenant le terme
			foreach my $doc (keys %docs) {
				# On extrait le TF
				my $TF = $docs{$doc};
				# On calcule le TFIDF
				my $numerateur = $TF * ($k + 1);
				my $denominateur = $TF + $k * (1 - $b + $b * $longueurDocuments{$doc} / $longueurMoyenne);
				my $score = $IDF * $numerateur / $denominateur;
				# On augmente la pertinence du document (le RSV)
				$pertinences{$doc} += $score;
			}
		}
	}
	return %pertinences;	
}

#####################
### Fréquentielle ###
#####################

sub frequentielle {
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
			# On extrait les documents qui contiennent le terme
			my $pointeurHash = $info -> {'documents'};
			my %docs = %$pointeurHash;
			# Pour chaque document contenant le terme
			foreach my $doc (keys %docs) {
				# Le mot est une fois dans le document
				$pertinences{$doc} += 1;
			}
		}
	}
	return %pertinences;	
}

############
### Cos² ###
############

sub cos2 {
	print 'To do :(';
}

####################
### Probabiliste ###
####################

sub probabiliste {
	print 'To do :(';
}
