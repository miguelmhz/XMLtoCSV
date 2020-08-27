#Packages
using EzXML
using DataFrames
using CSV
using CSVFiles


cd("C:\\Users\\migue\\Documents\\You-i-Lab\\SenSky\\EncuestasDinamicas")
Surveys=filter!(s->occursin(r".xml", s),readdir())

function addRow(df, row)
    finalRow = Dict()
    for name ∈ names(df)
        if haskey(row, name)
            finalRow[name] = row[name]
            delete!(row, name)
        else
            finalRow[name] = "NaN"
        end
    end
    for missingKey ∈ keys(row)
        insertcols!(df, missingKey => "NaN")
        finalRow[missingKey] = row[missingKey]
    end
    push!(df, finalRow)
    return df
end

function getAnswers(survey, document)
    answerArray=[]
    columnNames=[]
    push!(answerArray, document, "latitude", "longitude", "workshop-key", "survey-key", "capturedTimestamp", "storedTimestamp")
    push!(columnNames, "filePath", "latitude", "longitude", "workshop-key", "survey-key", "capturedTimestamp", "storedTimestamp")
    for topic in eachelement(survey)
        for Nquestion in eachelement(topic)
            push!(answerArray, nodecontent(findfirst("answer", Nquestion)) )
            push!(columnNames, "Q$(parse(Int, Nquestion["id"]))")
        end
    end
    answerArray=string.(answerArray)
    Survey= Dict(columnNames .=> answerArray)
    return Survey
end
    
filePath="C:\\Users\\migue\\Documents\\You-i-Lab\\SenSky\\SurveyCSV.csv"   


if !isfile(filePath)
   data = DataFrame(
    filePath = [""],
    latitude = [""],
    longitude = [""],
    workshopKey = [""],
    surveyKey = [""],
    capturedTimestamp = [""],
    storedTimestamp = [""]
)
    CSV.write(filePath,data)
end
if isfile(filePath)
    df=string.(DataFrame(load(filePath)))  
    for document in Surveys
        if size(df)==(0, 0)
            survey = root(readxml("$document"))
            global DF=addRow(df, getAnswers(survey, document))
        elseif document ∉ df[:,1] 
            survey = root(readxml("$document"))
            global DF=addRow(df, getAnswers(survey, document))
        end
    end
     CSV.write(filePath, DF)
end
          
println("Listo :)")



