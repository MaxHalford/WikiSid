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
# Créer un iframe pour éviter de faire de l'AJAX (c'est un hack)
print"
<style>
  .hide { position:absolute; top:-1px; left:-1px; width:1px; height:1px; }
</style>
<iframe id ='hiddenFrame' name='hiddenFrame' class='hide'></iframe>";

print"
<div class='container'>
	<blockquote>
	<form align='center' action='./changerParametres.pl' method='get'>
	
	<h1><small>Méthodes de scoring</small></h1>
		<div class='btn-group' data-toggle='buttons'>
			<label class='btn btn-success'>
				<input type='radio' name='methode' value='TFIDF'>TFIDF 
			</label>
			<label class='btn btn-success'>
				<input type='radio' name='methode' value='TFIDF_Variete'>TFIDF + Variété
			</label>
			<label class='btn btn-success'>
				<input type='radio' name='methode' value='Okapi_BM25'>Okapi BM25
			</label>
			<label class='btn btn-success'>
				<input type='radio' name='methode' value='Frequentielle'>Fréquentielle
			</label>
		</div>
	<h1><small>Page statistiques</small></h1>
		<h3><small>Nombre de documents analysés</small></h3>
		<div class='btn-group' data-toggle='buttons'>
			<input name=documents id='text' type='text' class='form-control' value=30>
		</div>
		<h3><small>Nombre de lemmes analysés</small></h3>
		<div class='btn-group' data-toggle='buttons'>
			<input name=lemmes id='text' type='text' class='form-control' value=50>
		</div>
		</br>
		</br>
	<button class='btn btn-info' type='submit'>
		Valider
	</button>
	</form>
	</blockquote>
	</br>
	
</div>
";

print "</body>
</html>";
