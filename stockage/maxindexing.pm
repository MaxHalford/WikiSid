#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use JSON;
use Encode;
use open qw/:std :utf8/;
use Lingua::Stem qw(stem);

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

sub sauvegarderIndex {
	# Paramètres
	my ($chemin, $nom, %index) = @_;
	my $json = encode_json \%index;
	open my $fichierJSON, '>', "$chemin/$nom.json" or die $!;
	print {$fichierJSON} Encode::decode('utf8', $json);
}

1;
