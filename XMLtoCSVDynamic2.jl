#Packages
using EzXML
using DataFrames
using CSV
using CSVFiles

cd("C:\\Users\\migue\\Documents\\You-i-Lab\\SenSky\\EncuestasDinamicas")
Surveys=filter!(s->occursin(r".xml", s),readdir())
#pwd()

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
    

for document in Surveys
    survey = root(readxml("$document"))
    AA=[]
    NamesCol=[]
    push!(AA, document, "latitude", "longitude", "workshop-key", "survey-key", "capturedTimestamp", "storedTimestamp")
    push!(NamesCol, "filePath", "latitude", "longitude", "workshop-key", "survey-key", "capturedTimestamp", "storedTimestamp")
    N=0
    
# Iterate over child elements.
  for topic in eachelement(survey)
# Get an attribute value by name.
        topics = topic["name"] 
        for Nquestion in eachelement(topic)
            push!(AA, nodecontent(findfirst("answer", Nquestion)) )
            N+=1
        end
    end
    
    for i in 1:N
         push!(NamesCol, "Q$(i)")
    end
    Survey= Dict(NamesCol .=> AA)

    pf="C:\\Users\\migue\\Documents\\You-i-Lab\\SenSky\\SurveyCSV.csv"   
    if isfile(pf) #VERIFY IF THE FILE ALREADY EXISTS
        df=string.(DataFrame(load(pf)))  
        if document ∉ df[:,1] 
        DF=addRow(df, Survey)
        CSV.write(pf, DF)
        end
    else  #CREATE FILE 
        df = DataFrame()
        for j in 1:length(AA)
        insertcols!(df, j, NamesCol[j] => AA[j])
        end    
        CSV.write(pf, df)
    end   
end
println("Listo :)")




