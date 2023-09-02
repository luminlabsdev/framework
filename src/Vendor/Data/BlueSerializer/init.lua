--!strict

local blueSerializer = { }
local serializerList = require(script.serializerList)

function blueSerializer.serialize<T>(value) : {} | T
	local valueType = typeof(value)
	
	local serializer = serializerList.serializers[valueType]
	if serializer then
		return serializer(value)
	end
	
	return value
end

function blueSerializer.deserialize<T>(value : {}) : T | {}
	local id = value[1]
	local deserializer = serializerList.deserializers[serializerList.idToType[id]]
	
	if deserializer then
		return deserializer(value)
	end
	
	return value
end

-- alias
blueSerializer.deSerialize = blueSerializer.deserialize
blueSerializer.Deserialize = blueSerializer.deserialize
blueSerializer.Serialize = blueSerializer.serialize

return table.freeze(blueSerializer)
