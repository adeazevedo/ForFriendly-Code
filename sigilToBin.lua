-- Register vertex connections
local vertex = {{}, {}, {}, {}, {}, {}, {}, {}, {}, false, false}

-- All the lines that intercepts a middle point. Used to spilt a big line in two smaller segments
local lines = {
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
    {1, 4, 7},
    {2, 5, 8},
    {3, 6, 9},
    {1, 5, 9},
    {3, 5, 7},
}

-- Function that split a line creating two segments connecting first and second point and second and third points
function split(a, b, c)
    table.remove(vertex[a], #vertex[a]) -- remove last item added
    connect(a, b)
    connect(b, c)
end

-- search an element in array and return its index
function search(tbl, value)
    for index, v in ipairs(tbl) do
        if v == value then return index end
    end

    return 0
end

-- Connect two vertices. A connection is always registed in the smaller vertice, for example: a connection
-- between vertex 9 and vertex 4 (connect(9, 4) or connect(4, 9)) 
-- will be registed in vertex 4 and vertex 9 will be empty
function connect(from, to, verticesTbl)
    local vertices = verticesTbl or vertex
    local min = math.min(from, to)
    local max = math.max(from, to)
    
    local index = search(vertices[min], max)
    if index > 0 then table.remove(vertices[min], index) end
    
    table.insert(vertices[min], max)
    
    for i = 1, 8 do
        local a, b, c = unpack(lines[i])
        if min == a and max == c then
            split(a, b, c)
        end
    end
end

-- Register a circle in symbol. Vertex[10] for top circle and vertex[11] for bottom circle 
-- Accepted values of "where": 'top', 'bottom', 'both'
function addCircle(where, verticesTbl)
    local vertices = verticesTbl or vertex
    if where:lower() == 'top' then vertices[10] = true end
    if where:lower() == 'bottom' then vertices[11] = true end
    if where:lower() == 'both' then vertices[10] = true; vertices[11] = true end
end

-- Verify if there is a connection between two vertices.
-- Return two values
--  1 or 0: number
--  true or false: boolean
function hasConnection(from, to, verticesTbl)
    local vertices = verticesTbl or vertex
    local min, max = math.min(from, to), math.max(from, to)
    local index = search(vertices[min], max)
    
    return (index > 0) and 1 or 0, index > 0
end

-- Verify if has a top circle
-- Return two values
--  1 or 0: number
--  true or false: boolean
function hasTopCircle(verticesTbl)
    local vertices = verticesTbl or vertex
    return (vertex[10] == true) and 1 or 0, vertex[10]
end

-- Verify if has a bottom circle
-- Return two values
--  1 or 0: number
--  true or false: boolean
function hasBottomCircle(verticesTbl)
    local vertices = verticesTbl or vertex
    return (vertex[11] == true) and 1 or 0, vertex[11]
end

-- Converts a number to binary string
function toBin(num)
    if num == 0 then return '0' end
    if num == 1 then return '1' end
    
    local rest = num % 2
    return toBin( math.floor((num - rest) / 2) ) .. tostring(rest)
end

-- Converts all vertices into a binary base number
-- Follow this pattern (H = Horizontal line, V = Vertical line, MD = Main Diagonal, SD = Secondary Diagonal, PD = Coprime Diagonal)
-- 30 - Bottom Circle
-- 29 - Top Circle

-- 28 - H(1, 2)
-- 27 - H(2, 3)
-- 26 - H(4, 5)
-- 25 - H(5, 6)
-- 24 - H(7, 8)
-- 23 - H(8, 9)

-- 22 - V(1, 4)
-- 21 - V(4, 7)
-- 20 - V(2, 5)
-- 19 - V(5, 8)
-- 18 - V(3, 6)
-- 17 - V(6, 9)

-- 16 - MD(4, 8)
-- 15 - MD(1, 5)
-- 14 - MD(5, 9)
-- 13 - MD(3, 6)

-- 12 - SD(2, 4)
-- 11 - SD(3, 5)
-- 10 - SD(5, 7)
-- 9 - SD(6, 8)

-- 8 - CD(9, 4)
-- 7 - CD(9, 2)
-- 6 - CD(7, 2)
-- 5 - CD(7, 6)
-- 4 - CD(3, 4)
-- 3 - CD(3, 8)
-- 2 - CD(1, 8)
-- 1 - CD(1, 6)
function verticesToBin(vertices)
    local line = {}

    --circles
    line[30] = hasBottomCircle(vertices)
    line[29] = hasTopCircle(vertices)
    
    -- horizontals
    line[28] = hasConnection(1, 2, vertices)
    line[27] = hasConnection(2, 3, vertices)
    line[26] = hasConnection(4, 5, vertices)
    line[25] = hasConnection(5, 6, vertices)
    line[24] = hasConnection(7, 8, vertices)
    line[23] = hasConnection(8, 9, vertices)
    
    --verticals
    line[22] = hasConnection(1, 4, vertices)
    line[21] = hasConnection(4, 7, vertices)
    line[20] = hasConnection(2, 5, vertices)
    line[19] = hasConnection(5, 8, vertices)
    line[18] = hasConnection(3, 6, vertices)
    line[17] = hasConnection(6, 9, vertices)
    
    --main diagonals (from left to right)
    line[16] = hasConnection(4, 8, vertices)
    line[15] = hasConnection(1, 5, vertices)
    line[14] = hasConnection(5, 9, vertices)
    line[13] = hasConnection(3, 6, vertices)

    --secondary diagonals (from right to left)
    line[12] = hasConnection(2, 4, vertices)
    line[11] = hasConnection(3, 5, vertices)
    line[10] = hasConnection(5, 7, vertices)
    line[9] = hasConnection(6, 8, vertices)
    
    --prime vertices
    line[8] = hasConnection(9, 4, vertices)
    line[7] = hasConnection(9, 2, vertices)
    line[6] = hasConnection(7, 2, vertices)
    line[5] = hasConnection(7, 6, vertices)
    line[4] = hasConnection(3, 4, vertices)
    line[3] = hasConnection(3, 8, vertices)
    line[2] = hasConnection(1, 8, vertices)
    line[1] = hasConnection(1, 6, vertices)
    
    return table.concat(line, '')
end

-- Converts a base2 number to base10
function binToDec(num)
    return tonumber(num, 2)
end

-- Converts a base2 number to vertices table
function binToVertices(bin)
    local iterator = string.gmatch(bin, '[{0,1}]')
    local binSplitted = {}
    
    for value in iterator do
        table.insert(binSplitted, value)
    end
    
    local tbl = {}
    local binIndex = #binSplitted
    for i = 30, 1, -1 do
        tbl[i] = binSplitted[binIndex] or '0'
        binIndex = binIndex - 1
    end
    
    local newVertices = {{}, {}, {}, {}, {}, {}, {}, {}, {}, false, false}
    local connectCallback = function(f, t)
        return function() connect(f, t , newVertices) end
    end
    local addCircleCallback = function(where)
        return function() addCircle(where, newVertices) end
    end
    
    local callbacks = {
        [1] = connectCallback(1, 6),
        [2] = connectCallback(1, 8),
        [3] = connectCallback(3, 8),
        [4] = connectCallback(3, 4),
        [5] = connectCallback(7, 6),
        [6] = connectCallback(7, 2),
        [7] = connectCallback(9, 2),
        [8] = connectCallback(9, 4),
        
        [9] = connectCallback(6, 8),
        [10] = connectCallback(5, 7),
        [11] = connectCallback(3, 5),
        [12] = connectCallback(2, 4),
        
        [13] = connectCallback(3, 6),
        [14] = connectCallback(5, 9),
        [15] = connectCallback(1, 5),
        [16] = connectCallback(4, 8),
        
        [17] = connectCallback(6, 9),
        [18] = connectCallback(3, 6),
        [19] = connectCallback(5, 8),
        [20] = connectCallback(2, 5),
        [21] = connectCallback(4, 7),
        [22] = connectCallback(1, 4),
        
        [23] = connectCallback(8, 9),
        [24] = connectCallback(7, 8),
        [25] = connectCallback(5, 6),
        [26] = connectCallback(4, 5),
        [27] = connectCallback(2, 3),
        [28] = connectCallback(1, 2),
        [29] = addCircleCallback("top"),
        [30] = addCircleCallback("bottom"),
    }
    
    for i, value in ipairs(tbl) do
        if value == '1' then
            callbacks[i]()
        end
    end
    
    return newVertices
end

function printVertices(vertices)
    for i, v in ipairs(vertices) do
        if type(v) == "table" then
            print("["..i.."] => {" .. table.concat(v, ',') .. "}")
        else
            print(v)
        end
    end
end


--------------------------------------------
-- Test Code
--------------------------------------------
-- Creating sigil (game sigil here)
connect(7, 1)
connect(1, 3)
connect(3, 9)
connect(9, 1)
connect(2, 8)
connect(7, 6)

--------------------------------------------
-- Printing all steps
--------------------------------------------
local vtb = verticesToBin(vertex)
local dec = binToDec(vtb)
local bin = toBin(dec)
local btv = binToVertices(toBin(dec))

print("From 'vertex':")
printVertices(vertex)
print()

print("Sigil to Binary: " .. vtb)
print("Binary to Decimal: " .. dec)
print("Decimal to Binary: " .. bin)

print()
print("Converting Binary to vertices:")
printVertices(btv)