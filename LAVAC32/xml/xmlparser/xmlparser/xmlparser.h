// Le bloc ifdef suivant est la façon standard de créer des macros qui facilitent l'exportation 
// à partir d'une DLL. Tous les fichiers contenus dans cette DLL sont compilés avec le symbole XMLPARSER_EXPORTS
// défini sur la ligne de commande. Ce symbole ne doit pas être défini pour un projet
// qui utilisent cette DLL. De cette manière, les autres projets dont les fichiers sources comprennent ce fichier considèrent les fonctions 
// XMLPARSER_API comme étant importées à partir d'une DLL, tandis que cette DLL considère les symboles
// définis avec cette macro comme étant exportés.
#ifdef XMLPARSER_EXPORTS
#define XMLPARSER_API __declspec(dllexport)
#else
#define XMLPARSER_API __declspec(dllimport)
#endif

extern "C" XMLPARSER_API int fnxmlparser(char * xmlFilename, char *szSearch,  char *szTitle,  char *szDescription,  char *szAuthor);
