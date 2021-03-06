
local composer = require( "composer" )
local gameNetwork = require( "gameNetwork" )
local widget = require( "widget" )

local scene = composer.newScene()

local radioGroup = display.newGroup()

composer.setVariable( "currentScore", 200 )
composer.setVariable( "currentLeaderboardID", "" )
composer.setVariable( "currentLeaderboardTitle", "" )


-- Radio button handler function
local function handleRadio( event )

	for j = 1,radioGroup.numChildren do
		if ( radioGroup[j].isOn == true and radioGroup[j].label ) then
			radioGroup[j].label:setFillColor( 1, 1, 1, 1 )
			composer.setVariable( "currentLeaderboardID", event.target.id )
			composer.setVariable( "currentLeaderboardTitle", event.target.title )
		elseif ( radioGroup[j].isOn == false and radioGroup[j].label ) then
			radioGroup[j].label:setFillColor( 1, 1, 1, 0.7 )
		end
	end
end


-- Game Center request listener function
local function requestCallback( event )

	if ( event.data ) then

		-- Event type of "setHighScore"
		if ( event.type == "setHighScore" ) then
			native.showAlert( "Result", event.data.value..' submitted to\n"'..composer.getVariable( "currentLeaderboardTitle" )..'" leaderboard.', { "OK" } )
		end
	end

	local printTable = composer.getVariable( "printTable" )
	printTable( event )
end


-- Button handler function
local function handleButton( event )

	local target = event.target

	-- Show leaderboard panel
	if ( target.id == "showLeaderboard" ) then
		gameNetwork.show( "leaderboards", { leaderboard={ category=composer.getVariable( "currentLeaderboardID" ) } } )

	-- Submit high score
	elseif ( target.id == "submitScore" ) then
		gameNetwork.request( "setHighScore",
			{
				localPlayerScore = { category=composer.getVariable( "currentLeaderboardID" ), value=composer.getVariable( "currentScore" ) },
				listener = requestCallback
			}
		)

	-- Decrement current score
	elseif ( target.id == "decScore" and composer.getVariable( "currentScore" ) >= 20 ) then
		composer.setVariable( "currentScore", composer.getVariable( "currentScore" ) - 10 )
		composer.getVariable( "submitButton" ):setLabel( "Submit ("..composer.getVariable( "currentScore" )..")" )

	-- Increment current score
	elseif ( target.id == "incScore" ) then
		composer.setVariable( "currentScore", composer.getVariable( "currentScore" ) + 10 )
		composer.getVariable( "submitButton" ):setLabel( "Submit ("..composer.getVariable( "currentScore" )..")" )
	end
	return true
end


function scene:create( event )

	local sceneGroup = self.view
	sceneGroup:insert( radioGroup )
	
	local decButton = widget.newButton{
		id = "decScore",
		label = "−10",
		onRelease = handleButton,
		emboss = false,
		fontSize = 17,
		shape = "rectangle",
		width = 52,
		height = 40,
		fillColor = { default={ 15/255, 80/255, 140/255, 1 }, over={ 15/255, 80/255, 140/255, 0.8 } },
		labelColor = { default={ 1, 1, 1, 1 }, over={ 1, 1, 1, 0.7 } }
	}
	decButton.x = display.contentCenterX - 98
	decButton.y = 352
	sceneGroup:insert( decButton )

	local incButton = widget.newButton{
		id = "incScore",
		label = "+10",
		onRelease = handleButton,
		emboss = false,
		fontSize = 17,
		shape = "rectangle",
		width = 52,
		height = 40,
		fillColor = { default={ 15/255, 80/255, 140/255, 1 }, over={ 15/255, 80/255, 140/255, 0.8 } },
		labelColor = { default={ 1, 1, 1, 1 }, over={ 1, 1, 1, 0.7 } }
	}
	incButton.x = display.contentCenterX - 38
	incButton.y = 352
	sceneGroup:insert( incButton )

	local submitButton = widget.newButton{
		id = "submitScore",
		label = "Submit ("..composer.getVariable( "currentScore" )..")",
		onRelease = handleButton,
		emboss = false,
		fontSize = 17,
		shape = "rectangle",
		width = 128,
		height = 40,
		fillColor = { default={ 28/255, 120/255, 200/255, 1 }, over={ 28/255, 120/255, 200/255, 0.8 } },
		labelColor = { default={ 1, 1, 1, 1 }, over={ 1, 1, 1, 0.7 } }
	}
	submitButton.x = display.contentCenterX + 60
	submitButton.y = 352
	sceneGroup:insert( submitButton )
	composer.setVariable( "submitButton", submitButton )

	local showLeaderboardButton = widget.newButton{
		id = "showLeaderboard",
		label = "Show Leaderboard",
		onRelease = handleButton,
		emboss = false,
		fontSize = 17,
		shape = "rectangle",
		width = 248,
		height = 40,
		fillColor = { default={ 80/255, 90/255, 170/255, 1 }, over={ 80/255, 90/255, 170/255, 0.8 } },
		labelColor = { default={ 1, 1, 1, 1 }, over={ 1, 1, 1, 0.7 } }
	}
	showLeaderboardButton.x = display.contentCenterX
	showLeaderboardButton.y = 408
	sceneGroup:insert( showLeaderboardButton )
	
	local ld = composer.getVariable( "leaderboardsData" )
	for i = 1,#ld do
		local on = false ; if ( i == 1 ) then on = true end
		local radioButton = widget.newSwitch{
			left = 40,
			top = 88+(i*36),
			style = "radio",
			id = ld[i].category,
			initialSwitchState = on,
			onPress = handleRadio
		}
		radioGroup:insert( radioButton )
		local radioLabel = display.newText( radioGroup, ld[i].title, 0, radioButton.y, "HelveticaNeue-Light", 18 )
		radioButton.label = radioLabel
		radioButton.title = ld[i].title
		radioLabel.anchorX = 0
		radioLabel.x = 80
		if ( i == 1 ) then
			radioLabel:setFillColor( 1, 1, 1, 1 )
			composer.setVariable( "currentLeaderboardID", radioButton.id )
			composer.setVariable( "currentLeaderboardTitle", radioButton.title )
		else
			radioLabel:setFillColor( 1, 1, 1, 0.7 )
		end
	end
end


scene:addEventListener( "create", scene )

return scene
