# XMLtoCSV.jl Documentación

XMLtoCSV es un script que permite procesar múltiples archivos XML para unificarlos en un archivo CSV.

---


## Registro de paquetes
``` julia
using Mongoc, CSV, CSVFiles, LightXML, DataFrames, DataStructures;
```
---
## Función addRow 
``` julia
function addRow(df, row)
```
### Parámetros 

* df - dataFrame donde se almacenará el contenido xml
* row - contenido xml que se agregará


### Qué hace la fucnión 
compruebe si el nuevo contenido xml tiene los mismos nombres de columnas que el dataFrame.
``` julia
finalRow = Dict()
    for name in names(df)
        if haskey(row, name)
            finalRow[name] = row[name]
            delete!(row, name)
        else
            finalRow[name] = "NaN"
        end
    end
```
### Qué retorna la función
Returns a new dataFrame with the new xml content added.


``` julia
finalRow = Dict()
    for missingKey in keys(row)
        insertcols!(df, missingKey => "NaN")
        finalRow[missingKey] = row[missingKey]
    end
    push!(df, finalRow)
    return df
```
--- 
## Función getAnswers 
``` julia
function getAnswers(survey, document)
```
### Parámetros 

* survey - xml document from which the content will be extracted
* document - name of the file


###  Qué hace la fucnión  
Agregue columnas fijas a un diccionario ordenado.
``` julia
 Survey= OrderedDict(
    "filePath" => document["file-path"],
    "latitude" => string(document["latitude"]),
    "longitude" => string(document["longitude"]),
    "workshopKey" => document["workshop-key"],
    "surveyKey" => document["survey-key"],
    "capturedTimestamp" => string(document["captured-timestamp"]),
    "storedTimestamp" => string(document["stored-timestamp"])
    )
```


Extraiga el contenido del documento xml de acuerdo con las etiquetas de respuesta y crea columnas en el diccionario de acuerdo con la identificación de la pregunta
``` julia
  for topic in get_elements_by_tagname(survey, "topic")
        for answer in get_elements_by_tagname(topic, "question")
            push!(Survey, "Q$(parse(Int, attribute(answer, "id")))" => content(find_element(answer, "answer")) )
        end
    end
    return Survey
```
### Qué retorna la función 
Devuelve un diccionario ordenado con el contenido xml.

---

## Implementación de código


``` julia
for document in occurrences
        doc = string(evidencesPath, document["file-path"])
        survey = root(parse_file("$doc"))
        if size(data)==(0, 0) || !(document in data[:,1])
            addRow(data, getAnswers(survey, document))
        end
    end
    CSV.write(output, data; delim=';')
    println("--Julia--> preprocessed CSV was updated.")
```



## Diagrama de flujo

![Diagrama de flujo del programa](https://i.ibb.co/ZTZtqbn/Diagrama.png)














