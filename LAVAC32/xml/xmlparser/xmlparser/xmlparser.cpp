// xmlparser.cpp : définit les fonctions exportées pour l'application DLL.
//


#include "stdafx.h"
#include "xmlparser.h"

using namespace std;

// change a char's encoding from UTF8 to ANSI
char* change_encoding_from_UTF8_to_ANSI(const char* szU8)
{ 
    int wcsLen = ::MultiByteToWideChar(CP_UTF8, NULL, szU8, strlen(szU8), NULL, 0);
    wchar_t* wszString = new wchar_t[wcsLen + 1];
    ::MultiByteToWideChar(CP_UTF8, NULL, szU8, strlen(szU8), wszString, wcsLen);
    wszString[wcsLen] = '\0';

    int ansiLen = ::WideCharToMultiByte(CP_ACP, NULL, wszString, wcslen(wszString), NULL, 0, NULL, NULL);
    char* szAnsi = new char[ansiLen + 1];
    ::WideCharToMultiByte(CP_ACP, NULL, wszString, wcslen(wszString), szAnsi, ansiLen, NULL, NULL);
    szAnsi[ansiLen] = '\0';

	delete[] wszString;

    return szAnsi;
}

// Il s'agit d'un exemple de fonction exportée.
XMLPARSER_API int fnxmlparser(char * xmlFilename, char *szSearch,  char *szTitle,  char *szDescription,  char *szAuthor)
{
	BOOL bMatch = FALSE;
	BOOL bOK = FALSE;

	char szSearch2[1024];
	strcpy_s(szSearch2, 1024, szSearch);
	strcat_s(szSearch2, 1024, " - ressource étudiant");
	//MessageBoxA(GetDesktopWindow(), szSearch2, "", MB_OK);

	TiXmlDocument doc(xmlFilename);
	if(!doc.LoadFile()){
	//    cerr << "erreur lors du chargement" << endl;
	//    cerr << "error #" << doc.ErrorId() << " : " << doc.ErrorDesc() << endl;
		return FALSE;
	}

	TiXmlHandle hdl(&doc);
	TiXmlElement *elem = hdl.FirstChildElement().FirstChildElement().Element();	

	while (elem && strcmp(elem->Value(), "ListRecords") != 0){
		elem = elem->NextSiblingElement(); // iteration 
	}	
	
	TiXmlElement *record = elem ? elem->FirstChildElement() : NULL;

	while (record && !bMatch){
		elem = record->FirstChildElement();
		while (elem && strcmp(elem->Value(), "metadata") != 0){
			elem = elem->NextSiblingElement(); // iteration 
		}
		if (elem) {
			char *psz = NULL;

			TiXmlElement *author = elem->FirstChildElement()->FirstChildElement();
			if (author) elem = author->FirstChildElement();
			while (elem && strcmp(elem->Value(), "lom:title") != 0){
				elem = elem->NextSiblingElement(); // iteration 
			}
			TiXmlElement *title = elem ? elem->FirstChildElement() : NULL;
			if (title) {
				psz = change_encoding_from_UTF8_to_ANSI(title->GetText());
				//if (_stricmp(psz, szSearch) == 0 || _stricmp(psz, szSearch2) == 0 || _strnicmp(psz, szSearch, strlen(szSearch)) == 0) 
				if (_strnicmp(psz, szSearch, strlen(szSearch)) == 0 || _stricmp(psz, szSearch2) == 0) 
				{
					//MessageBoxA(GetDesktopWindow(), psz, "", MB_OK);
					strcpy_s(szTitle, 1024, psz);
					bMatch = TRUE;
				}
				delete[] psz;
			}
			if (bMatch) {

				elem = elem->NextSiblingElement();
				while (elem && strcmp(elem->Value(), "lom:description") != 0){
					elem = elem->NextSiblingElement(); // iteration 
				}		
				TiXmlElement *description = elem ? elem->FirstChildElement() : NULL;
				if (description) {
					psz = change_encoding_from_UTF8_to_ANSI(description->GetText());
					//MessageBoxA(GetDesktopWindow(), psz, "", MB_OK);
					strcpy_s(szDescription, 4096, psz);
					delete[] psz;
				}

				if (author) author = author->NextSiblingElement();
				if (author) author = author->FirstChildElement();
				if (author) author = author->FirstChildElement();
				if (author) author = author->NextSiblingElement();
				if (author) {
					psz = change_encoding_from_UTF8_to_ANSI(author->GetText());
					//MessageBoxA(GetDesktopWindow(), psz, "", MB_OK);
					strcpy_s(szAuthor, 1024, psz);
					delete[] psz;
				}
			}
		}

		record = record->NextSiblingElement(); // iteration 
	}

	return bMatch;
}
