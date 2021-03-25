/*
	oINI Library by A_Samurai http://sites.google.com/site/ahkref/libraries/ini-object
	version 1.0.2
	date 2011/10/04
	licence: see the bottom of the file.
	tested on: Windows 7 64 bit AutoHotkey 32bit Unicode 1.1.04.01
*/

oINI_Load(IniContents) {
	;This function returns a two dimensional array of ini object. returns false on load failure.
	;Parameters:
	;	IniContents : INI text data or INI file path
	
	if FileExist(IniContents) {
		IniPath := IniContents
		FileRead, IniContents, %IniPath%
		If ErrorLevel
			Return False
	}

	;create an object with the custom base object
	oINI_baseObject := {oINI_INIFilePath: IniPath, oINI_OnTheFly: False, oINI_ErrorLevel: 0}	;define a custom base object
	oINI_baseObject.OnTheFly() := func("oINI_OnTheFlyMethod")	
	oINI_baseObject.Remove() := func("oINI_Remove")	
	oINI_baseObject.Insert() := func("oINI_Insert")	
	oINI_baseObject.Save() := func("oINI_Save")	
	oINI_baseObject.SetPath() := func("oINI_SetPath")
	oINI_baseObject.__Set := func("oINI__Set")	
	oINI_baseObject.Export() := func("oINI_Export")	
	TDArray := new oINI_baseObject	
		
	;insert the read sections and their key-value pairs into the two dimensional arrays.
    Needle = s)\[(?P<Section>.+?)]\R(?P<Keyvalues>.*?)(?=\R\[.+?]|$)
    mpos := 1   
    While (mpos := RegexMatch(IniContents, needle, m, mpos+Strlen(m))) {
		if !mSection
			Continue
		ObjInsert(TDArray, mSection, {base: oINI_SectionBaseObject(TDArray, mSection)})
        Loop, Parse, mKeyvalues, `n, `r		;parse by each line
			if RegExMatch(A_LoopField, "\s?;.*$") 	;comments, so skip it
				continue
            else if (epos := InStr(A_LoopField, "="))     ;a key is specified
				ObjInsert(TDArray[mSection], SubStr(A_LoopField, 1, epos-1), SubStr(A_LoopField, epos+1))
	}

	if IniPath
		TDArray.OnTheFly("True")

    Return TDArray
}
oINI_SetPath(ByRef this, INIFilePath) {
	;This function sets the file path to save
	this.base.oINI_INIFilePath := INIFilePath
}
oINI_Save(ByRef this, Section="", Overwrite=True, INIFilePath="") {
    ;This function writes the given two-dimensional array properties to an ini file.
	;Parameters:
	;	Section:
	;		if nothing is specified, all sections are saved; otherwise, only the specified section is saved.
	;	Overwrite : (the 2nd parameter)
	;		True: deletes the old data and replace them with the new ones.
	;		False: overrides the new data over the old data.
	;	INIFilePath : the file path to save ini contents.
	
	if !INIFilePath && this.oINI_INIFilePath
		INIFilePath := this.oINI_INIFilePath
	else if !this.oINI_INIFilePath && !INIFilePath 		;if no path specified, the function is nothing to do 
		return False

	OnTheFly := this.oINI_OnTheFly	;store the current oINI_OnTheFly status
	this.base.oINI_OnTheFly := True
    For fSection, Sections in this {
		if (Section && Section <> fSection) 
			Continue			;if the section name is specified in the third param and this parsed section is not the one to write, skip it
		removed := False
        For Key, Value in Sections {	;Sections is to section objects
			if overwrite && !removed {
				IniDelete, % INIFilePath, % fSection 			
				removed := True
			}
            IniWrite, % Value, % INIFilePath, % fSection, % Key	;fSection contains the section name
			if ErrorLevel {
				this.base.oINI_ErrorLevel := ErrorLevel
				this.base.oINI_OnTheFly := OnTheFly		;restore it
				Return False
			}
		}
	}
	this.base.oINI_OnTheFly := OnTheFly		;restore it
	Return True
}

oINI_OnTheFlyMethod(ByRef this, OnTheFly) {
	;This function sets the oINI_OnTheFly state to True/False and returns the set value. 
	;It returns false if the object does not have the file path to save the ini contents although True
	;is given for the OnTheFly state.
	
	if OnTheFly {
		if !FileExist(this.oINI_INIFilePath) 	
			this.base.oINI_OnTheFly := False
		else
			this.base.oINI_OnTheFly := True
	}	
	else
		this.base.oINI_OnTheFly := False
	Return this.oINI_OnTheFly
}
oINI_Section_Remove(ByRef this, params*) {	
	;This function overrides the default .Remove() method and removes the given key-value pair from the calling object
	;and if the oINI_OnTheFly state is true, it will update the ini file.
	;This function should be called by the root object.

	if (params.MaxIndex() = 1)
		ObjRemove(this, params.1)
	else 
		ObjRemove(this, params.1, params.2)
		
	oRoot := Object(this.oINI_RootObjectAddress)
	;if the file path is specifiled and the on-the-fly option is enabled, edit the ini file
	if oRoot.oINI_OnTheFly && oRoot.oINI_INIFilePath {
		IniDelete, % oRoot.oINI_INIFilePath, % this.oINI_ThisSection, % params.1 
		oRoot.base.oINI_ErrorLevel := ErrorLevel
	}
}
oINI_Remove(ByRef this, params*) {	
	;This function overrides the default .Remove() method and removes the given key-value pair from the calling object
	;and if the oINI_OnTheFly state is true, it will update the ini file.
	;This function should be called by child objects(section objects).
	
	if (params.MaxIndex() = 1)
		ObjRemove(this, params.1)
	else 
		ObjRemove(this, params.1, params.2)
	
	;if the file path is specifiled and the on-the-fly option is enabled, edit the ini file
	if this.oINI_OnTheFly && this.oINI_INIFilePath {
		if (params.MaxIndex() = 1)
			IniDelete, % this.oINI_INIFilePath, % params.1 
		else
			IniDelete, % this.oINI_INIFilePath, % params.1, % params.2
		this.base.oINI_ErrorLevel := ErrorLevel
	}
}
oINI_Section_Insert(ByRef this, params*) {
	;This function overrides the default .Insert() method and inserts the given key-value pair into the calling object
	;and if the oINI_OnTheFly state is true, it will update the ini file.
	;This function should be called by child objects(section objects).
	
	if (params.MaxIndex() = 1)
		ObjInsert(this, params.1)
	else 
		ObjInsert(this, params.1, params.2)
		
	oRoot := Object(this.oINI_RootObjectAddress)
	if oRoot.oINI_OnTheFly && oRoot.oINI_INIFilePath {
		IniWrite, % params.2, % oRoot.oINI_INIFilePath, % this.oINI_ThisSection, % params.1 	
		oRoot.base.oINI_ErrorLevel := ErrorLevel
	}	
}
oINI_Insert(this, params*) {				;for the root object
	;This function overrides the default .Insert() method and inserts the given key-value pair into the calling object
	;and if the oINI_OnTheFly state is true, it will update the ini file.
	;This function should be called by the root object
	
	if (params.MaxIndex() = 1)
		ObjInsert(this, params.1)
	else if IsObject(params.2) {
		;embed a base object into the newly created object 				
		params.2.base := oINI_SectionBaseObject(this, params.1)
		ObjInsert(this, params.1, params.2)
	} else
		ObjInsert(this, params.1, params.2)

	if this.oINI_OnTheFly && this.oINI_INIFilePath {
		if IsObject(params.2) {
			For key, value in params.2 
				IniWrite, % value, % this.oINI_INIFilePath, % params.1, % key		;params.1 is to the section name
		} else 
			IniWrite, % params.2, % this.oINI_INIFilePath, % params.1 
		this.base.oINI_ErrorLevel := ErrorLevel
	}	
}
oINI_Section__Set(this, params*) {		;for child objects (section objects)
	;This function is invoked when a new key-value pair is set in a child object(section object)
	;and if the oINI_OnTheFly state is true, it will update the ini file.
	;This function should be called by child objects(section objects).
	;Parameters
	;	this 	 : the caller object
	;	params.1 : the key
	;	params.2 : a value

	if (params.MaxIndex() = 1)
		ObjInsert(this, params.1)
	else 
		ObjInsert(this, params.1, params.2)	
	
	oRoot := Object(this.oINI_RootObjectAddress)
	if oRoot.oINI_OnTheFly && oRoot.oINI_INIFilePath {
		IniWrite, % params.2, % oRoot.oINI_INIFilePath, % this.oINI_ThisSection, % params.1 	
		oRoot.base.oINI_ErrorLevel := ErrorLevel
	}
	oRoot := ""
	Return False	;meta-functions need this 
}
oINI__Set(this, params*) {				;for the root object
	;This function is invoked when a new key-value (section-contants) pair is set in the root object
	;and if the oINI_OnTheFly state is true, it will update the ini file.
	;If the given value is text data, the function converts them to array elements
	;This function should be called by the root object.
	;Parameters
	;	this	 : the caller object
	;	params.1 : the section Name
	;	params.2 : a child object or ini text data
	
	param2 := params.2
	if IsObject(params.2) {
		params.2.base := oINI_SectionBaseObject(this, params.1)			;embed a base object into the newly created object 
		ObjInsert(this, params.1, params.2)
	}
	else {		;text data is passed. so convert them into array elements
		ObjInsert(this, params.1, {base: oINI_SectionBaseObject(this, params.1)})
		Loop, Parse, param2, `n, `r		;parse by each line
			If (epos := InStr(A_LoopField, "="))     ;a key is specified
				ObjInsert(this[params.1], SubStr(A_LoopField, 1, epos-1), SubStr(A_LoopField, epos+1))
	}
				
	if this.oINI_OnTheFly && this.oINI_INIFilePath {
		if IsObject(params.2) 
			For key, value in params.2 
				IniWrite, % value, % this.oINI_INIFilePath, % params.1, % key		;params.1 is to the section name		
		else if (params.MaxIndex() = 3)
			IniWrite, % params.3, % this.oINI_INIFilePath, % params.1, % params.2
		else
			IniWrite, % params.2, % this.oINI_INIFilePath, % params.1 
		this.base.oINI_ErrorLevel := ErrorLevel
	}
	Return False	;meta-functions need this 
}
oINI_SectionBaseObject(rootObj, oINI_ThisSection) {
	;This function creates a base object for section objects(child objects)

	oINI_SectionBaseObject := {oINI_RootObjectAddress: Object(rootObj), oINI_ThisSection: oINI_ThisSection}
	oINI_SectionBaseObject.Remove() := func("oINI_Section_Remove")
	oINI_SectionBaseObject.Insert() := func("oINI_Section_Insert")
	oINI_SectionBaseObject.__Set := func("oINI_Section__Set")		
	return oINI_SectionBaseObject
}
oINI_Export(this, FilePath, Format, Options="") {
	;This function export the ini object to a specified file format.
	;Curretnly it supports XML and CSV.
   
	if (Format = "xml")
		if oINI_ExportToXML(this, FilePath, Options)
			Return True
		else 
			Return False
	else if (Format = "csv")
		if oINI_ExportToCSV(this, FilePath, Options)
			Return True
		else
			Return False
	else
		Return False
}
oINI_ExportToCSV(this, FilePath, Header="Sections") {
	;This function is called from oINI_Export and converts the given two dimensional object into a CSV file.
	;Hearder: either Sections or Keys
	
	Header := Header ? Header : "Sections"
	if (Header = "Keys") {
		oKeys := [""]
		For Section, Sections in this {		;list all key names
			For key, value in Sections 		;the first line
				if !oINI_InList(oKeys, key) {
					oKeys.Insert(key)
					CSVContentsFirstLine .= """" key ""","
				}
		}
		CSVContents := """Sections""," RTrim(CSVContentsFirstLine, ",") "`n"
		For Section, Sections in this {		
			oRow := [Section]	;create the object with the first element
			For key, value in Sections {
				if (index := oINI_InList(oKeys, key))
					oRow.Insert(index, value) 	;insert the key with the information where it is supposed to be in
			}
			Loop, % oKeys.MaxIndex() 
				CSVContents .= (oRow[A_Index] ? """" oRow[A_Index] """," : """"",")	;insert values enclosed in double quotes
			CSVContents .= "`n"
		}
	} else {
		oRow := [], oKeys := []
		For Section, Sections in this 	{	;list all key names
			For key, value in Sections 		;the first line
				if !oINI_InList(oKeys, key) 
					oKeys.Insert(key)
			CSVContentsFirstLine .= """" Section ""","		
			oRow.Insert(Section)
		}
		CSVContents := "Keys," RTrim(CSVContentsFirstLine, ",") "`n"
		Loop, % oKeys.MaxIndex() {
			CSVContents .= oKeys[A_Index] ","	;the first element must be the key
			Index := A_Index 
			For Section, Sections in this {		;iterate per each section
				keymatch := False
				For key, value in Sections {
					if (key = oKeys[Index]) {
						CSVContents .= """" value ""","	;insert the key enclosed with double quotes
						keymatch := True
						Break
					}
				}
				if !keymatch
					CSVContents .= """"","				;insert the key enclosed with double quotes
			}
			CSVContents := RTrim(CSVContents, ",") "`n"
		}
	}
	
	FileDelete, % FilePath
	FileAppend, % CSVContents, % FilePath, % (A_IsUnicode ? "UTF-8" : "")
	If ErrorLevel
		Return False
	else
		Return True
}
oINI_InList(oHaystack, Needle, key=false) {
	;This function is called from oINI_ExportToCSV
	
	For index, value in oHaystack 
		if (value = Needle) && !key
			Return index
		else if (index = Needle) && key
			Return value
	Return False
}
oINI_ExportToXML(this, FilePath, RootNode="root") {
	;This function is called from oINI_Export and converts the given two dimensional object into a xml file.
	;Returns true if the file is created.
	
	RootNode := RootNode ? RootNode : "root"	
	oXML := ComObjCreate("MSXML2.DOMDocument")
	oXML.async := False 
	if !oXML.loadXML("<" RootNode "></" RootNode ">")
		Return False
	For Section, Sections in this {
		oXML.getElementsByTagName(RootNode).Item(0).appendChild(oXML.createElement(Section))
		For key, value in Sections {
			oXML.getElementsByTagName(Section).Item(num_sec_%Section% ? num_sec_%Section% : 0).appendChild(oXML.createElement(key))
			oXML.getElementsByTagName(key).Item(num_key_%key% ? num_key_%key% : 0).appendChild(oXML.createTextNode(value))
			++num_key_%key%
		}
		++num_sec_%Section%
	}
	FileDelete, % FilePath
	oXML.save(FilePath)
	oXML := ""
	if FileExist(FilePath)
		Return True
	else 
		Return False
}

/*
	The Version Log
	Updates: 		1.0.2 2011/10/04
		Fixed a bug that imported commented sections and key-value pairs
		Added the Export() method.
					1.0.1 2011/10/03	
		Fixed a bug not inserting a key-value pair when a regular assignment is performed in a child object(section object).
	Iitial Release: 1.0.0 2011/10/02

*/
/*
	Copyright 2011 A_Samurai. All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are
	permitted provided that the following conditions are met:

	   1. Redistributions of source code must retain the above copyright notice, this list of
		  conditions and the following disclaimer.

	   2. Redistributions in binary form must reproduce the above copyright notice, this list
		  of conditions and the following disclaimer in the documentation and/or other materials
		  provided with the distribution.

	THIS SOFTWARE IS PROVIDED BY A_Samurai ''AS IS'' AND ANY EXPRESS OR IMPLIED
	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL A_Samurai OR
	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

	The views and conclusions contained in the software and documentation are those of the
	authors and should not be interpreted as representing official policies, either expressed
	or implied, of A_Samurai.
*/
/*
	In short, this is a FreeBSD licence and you can modifiy and publish it under your license as long as
	it keeps the same license format, FreeBSD and gives credit to the original author. And any damege 
	caused by this software is your responsibility.	
*/