module Error

using ResultTypes

struct HTTPException <: Exception
    code::Int64
    message::String
end

export HTTPException

end