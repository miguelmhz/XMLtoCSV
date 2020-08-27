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
    push!(answerArray, document, 21.453643, -101.458375748, 2598, 432, 5677859435, 57684395473)
    push!(columnNames, "filePath", "latitude", "longitude", "workshopkey", "surveykey", "capturedTimestamp", "storedTimestamp")
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
    filePath = [],
    latitude = [],
    longitude = [],
    workshopkey = [],
    surveykey = [],
    capturedTimestamp = [],
    storedTimestamp = []
    ) 
else
    data=string.(DataFrame(load(filePath)))  
end

for document in Surveys
    survey = root(readxml("$document"))
    if size(data)==(0, 0)
        global DF=addRow(data, getAnswers(survey, document))
    elseif document ∉ data[:,1] 
        global DF=addRow(data, getAnswers(survey, document))
    end
end
    CSV.write(filePath, DF)
    
          
println("Listo :)")



