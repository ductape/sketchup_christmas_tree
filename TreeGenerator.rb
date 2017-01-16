

def makeBoard!(entities, length, width, thickness) 
  
  ptsBottom = []
  ptsBottom[0] = [-width/2, -length/2, -thickness/2]
  ptsBottom[1] = [-width/2, length/2, -thickness/2]
  ptsBottom[2] = [width/2, length/2, -thickness/2]
  ptsBottom[3] = [width/2, -length/2, -thickness/2]
  
  face = entities.add_face ptsBottom
  
  ptsTop = []
  ptsTop[0] = [-width/2, -length/2, thickness/2]
  ptsTop[1] = [-width/2, length/2, thickness/2]
  ptsTop[2] = [width/2, length/2, thickness/2]
  ptsTop[3] = [width/2, -length/2, thickness/2]
  
  face = entities.add_face ptsTop
  
  ptsLeftSide = []
  ptsLeftSide[0] = ptsTop[0]
  ptsLeftSide[1] = ptsTop[1]
  ptsLeftSide[2] = ptsBottom[1]
  ptsLeftSide[3] = ptsBottom[0]
  
  face = entities.add_face ptsLeftSide
  
  ptsRightSide = []
  ptsRightSide[0] = ptsTop[2]
  ptsRightSide[1] = ptsTop[3]
  ptsRightSide[2] = ptsBottom[3]
  ptsRightSide[3] = ptsBottom[2]
  
  face = entities.add_face ptsRightSide
  
  ptsFront = []
  ptsFront[0] = ptsTop[1]
  ptsFront[1] = ptsTop[2]
  ptsFront[2] = ptsBottom[2]
  ptsFront[3] = ptsBottom[1]
  
  face = entities.add_face ptsFront
  
  ptsBack = []
  ptsBack[0] = ptsTop[0]
  ptsBack[1] = ptsTop[3]
  ptsBack[2] = ptsBottom[3]
  ptsBack[3] = ptsBottom[0]
  
  face = entities.add_face ptsBack
end

def moveBoard!(group, z, angle)
  point = Geom::Point3d.new(0,0,0)
  vector = Geom::Vector3d.new(0,0,1)
  transform = Geom::Transformation.rotation(point, vector, angle)
  vectorTranslate = Geom::Vector3d.new(0,0,z)
  translate = Geom::Transformation.translation(vectorTranslate)
  
  group = group.transform!(transform)
  group = group.transform!(translate)
end

mod = Sketchup.active_model # Open model
ent = mod.entities # All entities in model
sel = mod.selection # Current selection

# clear model
ent.clear!

width = 12
length = 12 * 12 # 12 feet
thickness = 1.5
heightRatio = 1.5
maxRotation = 8.5.degrees
cutKerf = 0.25 # length of board lost to each cut
boardEnd = 1 # length to cut off of each end to clean it up
lumber_length = 16 * 12 # 16 feet

totalHeight = length * heightRatio
puts( 'Tree height: ' + (totalHeight / 12).to_s )

height = 0
rotation = 0
num_boards = 0
current_board_remaining = 0

while height < (totalHeight - (width * heightRatio)) do
  boardGroup = ent.add_group
  boardEnt = boardGroup.entities
  
  boardLength = (totalHeight - height) / heightRatio
  makeBoard!(boardEnt, boardLength, width, thickness)
  # rotation = height*10
  opposite = (width * 0.9) / 2
  adjacent = boardLength / 2
  angle = Math.tan(opposite / adjacent)
  if angle > (maxRotation)
    angle = maxRotation
  end
  rotation += angle * 2
  #puts 'Ang: ' << String(angle) << ' opp: ' << String(opposite) << ' adj: ' << String(adjacent) << ' rot: ' << String(rotation)
  moveBoard!(boardGroup, height, rotation)
  
  height += thickness
   
  if (boardLength + cutKerf) > current_board_remaining
    num_boards += 1
    current_board_remaining = lumber_length - (2 * boardEnd)
  end
  current_board_remaining += -(boardLength + cutKerf)
  
  puts( 'num boards: ' + num_boards.to_s + ' cur len: ' + boardLength.to_s + ' remaining: ' + current_board_remaining.to_s )
  
end

puts( 'Number boards: ' + num_boards.to_s )
