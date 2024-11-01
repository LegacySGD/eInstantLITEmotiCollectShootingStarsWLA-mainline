<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson,retrievePrizeTable,getType">
				<lxslt:script lang="javascript">
				<![CDATA[
					var debugFeed = [];
					var debugFlag = false; 
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNamesDesc)
					{						
						var scenario = getScenario(jsonContext);
						var scenarioMainGame = getMainGameData(scenario);
						var scenarioBonus = getBonusData(scenario);
						var convertedPrizeValues = (prizeValues.substring(1)).split('|').map(function(item) {return item.replace(/\t|\r|\n/gm, "")} );
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');

						////////////////////
						// Parse scenario //
						////////////////////

						const gridCols      = 6;
						const gridRows      = 6;

						var playAreaMinCol  = 1;
   						var playAreaMaxCol  = gridCols -2;
   						var playAreaMinRow  = 1;
   						var playAreaMaxRow  = gridRows -2;

						var doBonus = (scenarioBonus.length != 0);
						var triggerStr     = 'bonus';
						
						var playableCells = []; 
						var arrGridData  = [];
						var arrAuditData = [];

						function getPhasesData(A_arrGridData, A_arrAuditData)
						{
							var arrClusters   = [];
							var arrPhaseCells = [];
							var arrPhases     = [];
							var objCluster    = {};
							var objPhase      = {};

							if (A_arrAuditData != '')
							{
								for (var phaseIndex = 0; phaseIndex < A_arrAuditData.length; phaseIndex++)
								{
									objPhase = {arrGrid: [], arrClusters: []};

									for (var colIndex = 0; colIndex < gridCols; colIndex++)
									{
										objPhase.arrGrid.push(A_arrGridData[colIndex].substr(0,gridRows));
									}

									arrClusters   = A_arrAuditData[phaseIndex].split(":");
									arrPhaseCells = [];

									for (var clusterIndex = 0; clusterIndex < arrClusters.length; clusterIndex++)
									{
										objCluster = {strPrefix: '', arrCells: []};

										objCluster.strPrefix = arrClusters[clusterIndex][0];

										objCluster.arrCells = arrClusters[clusterIndex].slice(1).match(new RegExp('.{1,2}', 'g')).map(function(item) {return parseInt(item,10);} );

										objPhase.arrClusters.push(objCluster);

										arrPhaseCells = arrPhaseCells.concat(objCluster.arrCells);
									}

									arrPhases.push(objPhase);

									arrPhaseCells.sort(function(a,b) {return b-a;} );

									for (var cellIndex = 0; cellIndex < arrPhaseCells.length; cellIndex++)
									{
										if (cellIndex == 0 || (cellIndex > 0 && arrPhaseCells[cellIndex] != arrPhaseCells[cellIndex-1]))
										{
											cellCol = Math.floor((arrPhaseCells[cellIndex]-1) / gridRows);
											cellRow = (arrPhaseCells[cellIndex]-1) % gridRows;

											if (cellCol >= 0 && cellCol < gridCols)
											{			
												A_arrGridData[cellCol] = A_arrGridData[cellCol].substring(0,cellRow) + A_arrGridData[cellCol].substring(cellRow+1);
											}
										}
									}
								}
							}

							objPhase = {arrGrid: [], arrClusters: []};

							for (var colIndex = 0; colIndex < gridCols; colIndex++)
							{
								objPhase.arrGrid.push(A_arrGridData[colIndex].substr(0,gridRows));
							}

							arrPhases.push(objPhase);

							return arrPhases;
						}

						arrGridData  = scenarioMainGame.split(":")[0].split(",");
						arrAuditData = scenarioMainGame.split(":").slice(1).join(":").split(",");
						var mgPhases = getPhasesData(arrGridData, arrAuditData);

						///////////////////////
						// Output Game Parts //
						///////////////////////
						const symbPrizes       = 'ABCDEFG';
						const symbWild         = 'W';
						const symbBonusWin     = 'Z';
						const symbSpecials     = symbWild + symbBonusWin;
						const symbActions      = 'QRSTUV';
						const symbAllActions   = symbActions; 
						const symbBonusPrizes  = 'ABCDEF';
						const symbBonusWins    = '123WX';

						const cellSize      = 24;
						const cellMargin    = 1;
						const cellTextX     = 13;
						const cellTextY     = 15;
						const colourAquamarine = '#7fffd4';
						const colourBlack   = '#000000';
						const colourBlue    = '#99ccff';
						const colourBrown   = '#990000';
						const colourGreen   = '#00cc00';
						const colourMidGreen= '#00ff00';
						const colourDkGrey  = '#202020';
						const colourMidGrey = '#7c7c7c';
						const colourLemon   = '#ffff99';
						const colourLilac   = '#ccccff';
						const colourLime    = '#ccff99';
						const colourDeepMag = '#b300b3';
						const colourNavy    = '#0000ff';
						const colourOrange  = '#ff7c00';
						const colourPeach   = '#ffcc99';
						const colourPink    = '#ffccff';
						const colourPurple  = '#cc99ff';
						const colourRed     = '#ff9999';
						const colourScarlet = '#ff0000';
						const colourWhite   = '#ffffff';
						const colourYellow  = '#ffff00';

						const prizeColours       = [colourLemon, colourPink, colourPurple, colourBlue, colourRed, colourAquamarine, colourPeach];
						const specialBoxColours  = [colourScarlet, colourNavy];
						const specialTextColours = [colourYellow, colourYellow];

						const bonusBoxColours    = [colourLemon, colourPink, colourPurple, colourBlue, colourRed, colourAquamarine, colourPeach];
						const bonusSBoxColours   = [colourOrange, colourNavy, colourDeepMag, colourScarlet, colourMidGrey];
						const bonusSTextColours  = [colourYellow, colourYellow, colourYellow, colourYellow, colourYellow];

						var r = [];

						var boxColourStr  = '';
						var canvasIdStr   = '';
						var elementStr    = '';
						var symbAction    = '';
						var symbDesc      = '';
						var symbPrize     = '';
						var symbSpecial   = '';
						var symbBonus     = '';
						var textColourStr = '';

						function showSymb(A_strCanvasId, A_strCanvasElement, A_strBoxColour, A_strTextColour, A_strText)
						{
							var canvasCtxStr = 'canvasContext' + A_strCanvasElement;

							r.push('<canvas id="' + A_strCanvasId + '" width="' + (cellSize + 2 * cellMargin).toString() + '" height="' + (cellSize + 2 * cellMargin).toString() + '"></canvas>');
							r.push('<script>');
							r.push('var ' + A_strCanvasElement + ' = document.getElementById("' + A_strCanvasId + '");');
							r.push('var ' + canvasCtxStr + ' = ' + A_strCanvasElement + '.getContext("2d");');
							r.push(canvasCtxStr + '.font = "bold 14px Arial";');
							r.push(canvasCtxStr + '.textAlign = "center";');
							r.push(canvasCtxStr + '.textBaseline = "middle";');
							r.push(canvasCtxStr + '.strokeRect(' + (cellMargin + 0.5).toString() + ', ' + (cellMargin + 0.5).toString() + ', ' + cellSize.toString() + ', ' + cellSize.toString() + ');');
							r.push(canvasCtxStr + '.fillStyle = "' + A_strBoxColour + '";');
							r.push(canvasCtxStr + '.fillRect(' + (cellMargin + 1.5).toString() + ', ' + (cellMargin + 1.5).toString() + ', ' + (cellSize - 2).toString() + ', ' + (cellSize - 2).toString() + ');');
							r.push(canvasCtxStr + '.fillStyle = "' + A_strTextColour + '";');
							r.push(canvasCtxStr + '.fillText("' + A_strText + '", ' + cellTextX.toString() + ', ' + cellTextY.toString() + ');');

							r.push('</script>');
						}

						///////////////////////
						// Prize Symbols Key //
						///////////////////////
						r.push('<div style="float:left; margin-right:50px">');
						r.push('<p>' + getTranslationByName("titlePrizeSymbolsKey", translations) + '</p>');

						r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
						r.push('<tr class="tablehead">');
						r.push('<td>' + getTranslationByName("keySymbol", translations) + '</td>');
						r.push('<td>' + getTranslationByName("keyDescription", translations) + '</td>');
						r.push('</tr>');

						for (var prizeIndex = 0; prizeIndex < symbPrizes.length; prizeIndex++)
						{
							symbPrize    = symbPrizes[prizeIndex];
							canvasIdStr  = 'cvsKeySymb' + symbPrize;
							elementStr   = 'keyPrizeSymb' + symbPrize;
							boxColourStr = prizeColours[prizeIndex];
							symbDesc     = 'symb' + symbPrize;

							r.push('<tr class="tablebody">');
							r.push('<td align="center">');

							showSymb(canvasIdStr, elementStr, boxColourStr, colourBlack, symbPrize);

							r.push('</td>');
							r.push('<td>' + getTranslationByName(symbDesc, translations) + '</td>');
							r.push('</tr>');
						}

						r.push('</table>');
						r.push('</div>');

						/////////////////////////
						// Special Symbols Key //
						/////////////////////////
						r.push('<div style="float:left; margin-right:50px">');
						r.push('<p>' + getTranslationByName("titleSpecialSymbolsKey", translations) + '</p>');

						r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
						r.push('<tr class="tablehead">');
						r.push('<td>' + getTranslationByName("keySymbol", translations) + '</td>');
						r.push('<td>' + getTranslationByName("keyDescription", translations) + '</td>');
						r.push('</tr>');

						for (var specialIndex = 0; specialIndex < symbSpecials.length; specialIndex++)
						{
							symbSpecial   = symbSpecials[specialIndex];
							canvasIdStr   = 'cvsKeySymb' + symbSpecial;
							elementStr    = 'keySpecialSymb' + symbSpecial;
							boxColourStr  = specialBoxColours[specialIndex];
							textColourStr = specialTextColours[specialIndex];
							symbDesc      = 'symb' + symbSpecial;

							r.push('<tr class="tablebody">');
							r.push('<td align="center">');

							showSymb(canvasIdStr, elementStr, boxColourStr, textColourStr, symbSpecial);

							r.push('</td>');
							r.push('<td>' + getTranslationByName(symbDesc, translations) + '</td>');
							r.push('</tr>');
						}

						r.push('</table>');
						r.push('</div>');

						////////////////////////
						// Action Symbols Key //
						////////////////////////
						r.push('<div style="float:left">');
						r.push('<p>' + getTranslationByName("titleActionSymbolsKey", translations) + '</p>');

						r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
						r.push('<tr class="tablehead">');
						r.push('<td>' + getTranslationByName("keySymbol", translations) + '</td>');
						r.push('<td>' + getTranslationByName("keyDescription", translations) + '</td>');
						r.push('</tr>');

						for (var actionIndex = 0; actionIndex < symbActions.length; actionIndex++)
						{
							symbAction  = symbActions[actionIndex];
							canvasIdStr = 'cvsKeySymb' + symbAction;
							elementStr  = 'keyActionSymb' + symbAction;
							symbDesc    = 'symb' + symbAction;

							r.push('<tr class="tablebody">');
							r.push('<td align="center">');

							showSymb(canvasIdStr, elementStr, colourBrown, colourWhite, symbAction);

							r.push('</td>');
							r.push('<td>' + getTranslationByName(symbDesc, translations) + '</td>');
							r.push('</tr>');
						}

						r.push('</table>');
						r.push('</div>');

						///////////////
						// Main Game //
						///////////////
						const mgClusterSizes = [3,4,5,6,7,8];
						const isMainGrid     = true;

						var bonusCounts      = symbSpecials.split("").map(function(item) {return 0;} );
						var bonusTriggers    = symbSpecials.split("").map(function(item) {return 3;} );
						var countText        = '';
						var gridCanvasHeight = gridRows * cellSize + 2 * cellMargin;
						var gridCanvasWidth  = gridCols * cellSize + 2 * cellMargin;
						var isAction         = false;
						var isBonusSymbs     = false;
						var isCluster        = false;
						var phaseStr         = '';
						var prefixIndex      = -1;
						var prizeCount       = 0;
						var prizeCountActual = 0;
						var prizeStr         = '';
						var prizeText        = '';
						var triggerText      = '';

						function showGridSymbs(A_strCanvasId, A_strCanvasElement, A_arrGrid)
						{
							var canvasCtxStr  = 'canvasContext' + A_strCanvasElement;
							var cellIndex     = -1;
							var cellNum       = 0;
							var cellX         = 0;
							var cellY         = 0;
							var isPrizeCell   = false;
							var isSpecialCell = false;
							var isValid       = false;
							var symbCell      = '';
							var symbIndex     = -1;

							r.push('<canvas id="' + A_strCanvasId + '" width="' + gridCanvasWidth.toString() + '" height="' + gridCanvasHeight.toString() + '"></canvas>');
							r.push('<script>');
							r.push('var ' + A_strCanvasElement + ' = document.getElementById("' + A_strCanvasId + '");');
							r.push('var ' + canvasCtxStr + ' = ' + A_strCanvasElement + '.getContext("2d");');
							r.push(canvasCtxStr + '.textAlign = "center";');
							r.push(canvasCtxStr + '.textBaseline = "middle";');

							for (var gridCol = 0; gridCol < gridCols; gridCol++)
							{
								for (var gridRow = 0; gridRow < gridRows; gridRow++)
								{
									cellNum++;
							
									isValid		  = (playableCells.indexOf(cellNum) != -1); 
									symbCell      = (isValid) ? A_arrGrid[gridCol][gridRow] : '';
									isPrizeCell   = (symbPrizes.indexOf(symbCell) != -1);
									isSpecialCell = (symbSpecials.indexOf(symbCell) != -1);
									symbIndex     = (isPrizeCell) ? symbPrizes.indexOf(symbCell) : ((isSpecialCell) ? symbSpecials.indexOf(symbCell) : -1);
									boxColourStr  = (isValid) ? ((isPrizeCell) ? prizeColours[symbIndex] : ((isSpecialCell) ? specialBoxColours[symbIndex] : colourBrown)) : colourDkGrey;
									textColourStr = (isPrizeCell) ? colourBlack : ((isSpecialCell) ? specialTextColours[symbIndex] : colourWhite);
									cellX         = gridCol * cellSize;
									cellY         = (gridRows - gridRow - 1) * cellSize;

									r.push(canvasCtxStr + '.font = "bold 14px Arial";');
									r.push(canvasCtxStr + '.strokeRect(' + (cellX + cellMargin + 0.5).toString() + ', ' + (cellY + cellMargin + 0.5).toString() + ', ' + cellSize.toString() + ', ' + cellSize.toString() + ');');
									r.push(canvasCtxStr + '.fillStyle = "' + boxColourStr + '";');
									r.push(canvasCtxStr + '.fillRect(' + (cellX + cellMargin + 1.5).toString() + ', ' + (cellY + cellMargin + 1.5).toString() + ', ' + (cellSize - 2).toString() + ', ' + (cellSize - 2).toString() + ');');
									r.push(canvasCtxStr + '.fillStyle = "' + textColourStr + '";');
									r.push(canvasCtxStr + '.fillText("' + symbCell + '", ' + (cellX + cellTextX).toString() + ', ' + (cellY + cellTextY).toString() + ');');
								}
							}
							r.push('</script>');
						}

						function showAuditSymbs(A_strCanvasId, A_strCanvasElement, A_arrGrid, A_arrData)
						{
							var canvasCtxStr  = 'canvasContext' + A_strCanvasElement;
							var cellX         = 0;
							var cellY         = 0;
							var isActionCell  = false;
							var isClusterCell = false;
							var isPrizeCell   = false;
							var isSpecialCell = false;
							var isValid       = false;
							var isWildCell    = false;
							var symbCell      = '';
							var symbIndex     = -1;
							var cellNum       = 0;

							r.push('<canvas id="' + A_strCanvasId + '" width="' + (gridCanvasWidth + 25).toString() + '" height="' + gridCanvasHeight.toString() + '"></canvas>');
							r.push('<script>');
							r.push('var ' + A_strCanvasElement + ' = document.getElementById("' + A_strCanvasId + '");');
							r.push('var ' + canvasCtxStr + ' = ' + A_strCanvasElement + '.getContext("2d");');
							r.push(canvasCtxStr + '.textAlign = "center";');
							r.push(canvasCtxStr + '.textBaseline = "middle";');

							for (var gridCol = 0; gridCol < gridCols; gridCol++)
							{
								for (var gridRow = 0; gridRow < gridRows; gridRow++)
								{
									cellNum++;

									isClusterCell = (A_arrData.arrCells.indexOf(cellNum) != -1);
									isValid		  = (playableCells.indexOf(cellNum) != -1); 
									isWildCell    = (isClusterCell && A_arrGrid[gridCol][gridRow] == symbWild);									
									symbCell      = ('0' + cellNum).slice(-2);
									isSpecialCell = (isWildCell || (isClusterCell && symbSpecials.indexOf(A_arrData.strPrefix) != -1));
									isPrizeCell   = (!isSpecialCell && isClusterCell && symbPrizes.indexOf(A_arrData.strPrefix) != -1);									
									isActionCell  = (isClusterCell && symbAllActions.indexOf(A_arrData.strPrefix) != -1);
									symbIndex     = (isPrizeCell) ? symbPrizes.indexOf(A_arrData.strPrefix) : ((isSpecialCell) ? ((isWildCell) ? symbSpecials.indexOf(symbWild) : symbSpecials.indexOf(A_arrData.strPrefix)) : -1);
									boxColourStr  = (isValid) ? ((isPrizeCell) ? prizeColours[symbIndex] : ((isSpecialCell) ? specialBoxColours[symbIndex] : ((isActionCell) ? colourBrown : colourWhite))) : colourDkGrey;
									textColourStr = (isPrizeCell) ? colourBlack : ((isSpecialCell) ? specialTextColours[symbIndex] : ((isActionCell) ? colourWhite : colourBlack));
									cellX         = gridCol * cellSize;
									cellY         = (gridRows - gridRow - 1) * cellSize;

									r.push(canvasCtxStr + '.font = "bold 14px Arial";');
									r.push(canvasCtxStr + '.strokeRect(' + (cellX + cellMargin + 0.5).toString() + ', ' + (cellY + cellMargin + 0.5).toString() + ', ' + cellSize.toString() + ', ' + cellSize.toString() + ');');
									r.push(canvasCtxStr + '.fillStyle = "' + boxColourStr + '";');
									r.push(canvasCtxStr + '.fillRect(' + (cellX + cellMargin + 1.5).toString() + ', ' + (cellY + cellMargin + 1.5).toString() + ', ' + (cellSize - 2).toString() + ', ' + (cellSize - 2).toString() + ');');
									r.push(canvasCtxStr + '.fillStyle = "' + textColourStr + '";');
									r.push(canvasCtxStr + '.fillText("' + symbCell + '", ' + (cellX + cellTextX).toString() + ', ' + (cellY + cellTextY).toString() + ');');
								}
							}

							r.push('</script>');
						}

						function setupPlayableCells() 
						{
							playableCells = [];
   							for (var colCount = playAreaMinCol; colCount <= playAreaMaxCol; colCount++)
							{
						    	for (var rowCount = playAreaMinRow; rowCount <= playAreaMaxRow; rowCount++)
								{
         							playableCells.push((colCount) * gridCols + rowCount +1);
								}
							}
						}

						r.push('<div style="clear:both">');
						r.push('<p> <br>' + getTranslationByName("mainGame", translations).toUpperCase() + '</p>');

						r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');

						var gridSymb = '';
						var pAMiR = playAreaMinRow;
						var pAMaR = playAreaMaxRow;
						var pAMiC = playAreaMinCol;
						var pAMaC = playAreaMaxCol;

						for (var phaseIndex = 0; phaseIndex < mgPhases.length; phaseIndex++)
						{
							// Check to see if there's an action to add extra cells
							for (var gridCol = playAreaMinCol; gridCol <= playAreaMaxCol; gridCol++)
							{
								for (var gridRow = playAreaMinCol; gridRow <= playAreaMaxRow; gridRow++)
								{
									gridSymb = mgPhases[phaseIndex].arrGrid[gridCol][gridRow];
									if (symbActions.indexOf(gridSymb) > -1)
									{
										switch (gridSymb)
										{
											case "Q": // Expand Up
												pAMaR = gridRows -1;
											break;
											case "R": // Expand Right
												pAMaC = gridCols -1;
											break;
											case "S": // Expand Down
												pAMiR = 0;
											break;
											case "T": // Expand Left
												pAMiC = 0;
											break;
											case "U": // Expand Up and Down
												pAMiR = 0;
         										pAMaR = gridRows -1;
											break;
											case "V": // Expand Left and Right
	         									pAMiC = 0;
		 										pAMaC = gridCols -1;
											break;
										}
									}
								}
							}
							playAreaMinRow = pAMiR;
							playAreaMaxRow = pAMaR;
							playAreaMinCol = pAMiC;
							playAreaMaxCol = pAMaC;

							setupPlayableCells();

							//////////////////////////
							// Main Game Phase Info //
							//////////////////////////

							phaseStr = getTranslationByName("phaseNum", translations) + ' ' + (phaseIndex+1).toString() + ' ' + getTranslationByName("phaseOf", translations) + ' ' + mgPhases.length.toString();

							r.push('<tr class="tablebody">');
							r.push('<td valign="top">' + phaseStr + '</td>');

							////////////////////
							// Main Game Grid //
							////////////////////

							canvasIdStr = 'cvsMainGrid' + phaseIndex.toString();
							elementStr  = 'phaseMainGrid' + phaseIndex.toString();

							r.push('<td style="padding-left:50px; padding-right:50px; padding-bottom:25px">');

							showGridSymbs(canvasIdStr, elementStr, mgPhases[phaseIndex].arrGrid);

							r.push('</td>');

							/////////////////////////////////////////
							// Main Game Clusters or trigger cells //
							/////////////////////////////////////////

							r.push('<td style="padding-right:50px; padding-bottom:25px">');

							for (clusterIndex = 0; clusterIndex < mgPhases[phaseIndex].arrClusters.length; clusterIndex++)
							{
								canvasIdStr = 'cvsMainAudit' + phaseIndex.toString() + '_' + clusterIndex.toString();
								elementStr  = 'phaseMainAudit' + phaseIndex.toString() + '_' + clusterIndex.toString();

								showAuditSymbs(canvasIdStr, elementStr, mgPhases[phaseIndex].arrGrid, mgPhases[phaseIndex].arrClusters[clusterIndex]);
							}

							r.push('</td>');

							//////////////////////////////////////
							// Main Game Prizes or trigger text //
							//////////////////////////////////////

							r.push('<td valign="top" style="padding-bottom:25px">');

							if (mgPhases[phaseIndex].arrClusters.length > 0)
							{
								r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');

								for (var clusterIndex = 0; clusterIndex < mgPhases[phaseIndex].arrClusters.length; clusterIndex++)
								{
									symbPrize        = mgPhases[phaseIndex].arrClusters[clusterIndex].strPrefix;
									isCluster        = (symbPrizes.indexOf(symbPrize) != -1);
									isBonusSymbs     = (symbSpecials.indexOf(symbPrize) != -1);
									isAction         = (symbAllActions.indexOf(symbPrize) != -1);
									canvasIdStr      = 'cvsMainClusterPrize' + phaseIndex.toString() + '_' + clusterIndex.toString() + symbPrize;
									elementStr       = 'mainClusterPrizeSymb' + phaseIndex.toString() + '_' + clusterIndex.toString() + symbPrize;
									prefixIndex      = (isCluster) ? symbPrizes.indexOf(symbPrize) : ((isBonusSymbs) ? symbSpecials.indexOf(symbPrize) : -1);
									boxColourStr     = (isCluster) ? prizeColours[prefixIndex] : ((isBonusSymbs) ? specialBoxColours[prefixIndex] : colourBrown);
									textColourStr    = (isCluster) ? colourBlack : ((isBonusSymbs) ? specialTextColours[prefixIndex] : colourWhite);
									prizeCount       = mgPhases[phaseIndex].arrClusters[clusterIndex].arrCells.length;
									prizeCountActual = prizeCount;

									if (isCluster)
									{
										while (mgClusterSizes.indexOf(prizeCount) == -1)
										{
											prizeCount--;
										}
									}

									prizeText = symbPrize + prizeCount.toString();									

									if (isBonusSymbs)
									{
										bonusCounts[prefixIndex] += prizeCount;

										triggerText = (bonusCounts[prefixIndex] == bonusTriggers[prefixIndex]) ? ' : ' + getTranslationByName(triggerStr, translations) + ' ' + getTranslationByName("triggered", translations) : '';
									}

									countText = (isCluster || isBonusSymbs) ? prizeCountActual.toString() + ' x' : '';

									prizeStr  = (isCluster) ? convertedPrizeValues[getPrizeNameIndex(prizeNames, prizeText)] : ((isBonusSymbs) ? getTranslationByName("collected", translations) + ' ' + (bonusCounts[prefixIndex]).toString() + ' ' + getTranslationByName("phaseOf", translations) + ' ' + (bonusTriggers[prefixIndex]).toString() + triggerText : ((isAction) ? getTranslationByName('symb' + symbPrize, translations) : ''));

									r.push('<tr class="tablebody">');
									r.push('<td>' + countText + '</td>');
									r.push('<td align="center">');

									showSymb(canvasIdStr, elementStr, boxColourStr, textColourStr, symbPrize);
									
									r.push('</td>');
									r.push('<td>' + prizeStr + '</td>');
									r.push('</tr>');
								}

								r.push('</table>');
							}

							r.push('</td>');
							r.push('</tr>');
						}

						r.push('</table>');
						r.push('</div>');

						////////////////
						// Bonus Game //
						////////////////
						if (doBonus)
						{
							function pad(num, size) 
							{
 								num = num.toString();
							    while (num.length < size) num = "0" + num;
    							return num;
							}

							function showBonusSymbs(A_strCanvasId, A_strCanvasElement, A_strGrid)
							{
								var canvasCtxStr = 'canvasContext' + A_strCanvasElement;
								var cellIndex    = -1;
								var cellX        = 0;
								var cellY        = 0;
								var isPrizeCell  = false;
								var isWinCell    = false;
								var symbCell     = '';
								var symbIndex    = -1;

								r.push('<canvas id="' + A_strCanvasId + '" width="' + gridCanvasWidth.toString() + '" height="' + gridCanvasHeight.toString() + '"></canvas>');
								r.push('<script>');
								r.push('var ' + A_strCanvasElement + ' = document.getElementById("' + A_strCanvasId + '");');
								r.push('var ' + canvasCtxStr + ' = ' + A_strCanvasElement + '.getContext("2d");');
								r.push(canvasCtxStr + '.textAlign = "center";');
								r.push(canvasCtxStr + '.textBaseline = "middle";');

								for (var gridCol = 0; gridCol < gridCols; gridCol++)
								{
									for (var gridRow = 0; gridRow < gridRows; gridRow++)
									{
										cellIndex     = gridCol * gridRows + gridRow;
										symbCell      = A_strGrid[cellIndex];
										isWinCell     = (symbCell == symbBonusWin);
										isPrizeCell   = (symbPrizes.indexOf(symbCell) != -1);
										symbIndex     = (isPrizeCell) ? symbPrizes.indexOf(symbCell) : -1;
										boxColourStr  = (isWinCell) ? colourGreen : prizeColours[symbIndex];
										textColourStr = (isWinCell) ? colourYellow : colourBlack;
										cellX         = gridCol * cellSize;
										cellY         = (gridRows - gridRow - 1) * cellSize;

										r.push(canvasCtxStr + '.font = "bold 14px Arial";');
										r.push(canvasCtxStr + '.strokeRect(' + (cellX + cellMargin + 0.5).toString() + ', ' + (cellY + cellMargin + 0.5).toString() + ', ' + cellSize.toString() + ', ' + cellSize.toString() + ');');
										r.push(canvasCtxStr + '.fillStyle = "' + boxColourStr + '";');
										r.push(canvasCtxStr + '.fillRect(' + (cellX + cellMargin + 1.5).toString() + ', ' + (cellY + cellMargin + 1.5).toString() + ', ' + (cellSize - 2).toString() + ', ' + (cellSize - 2).toString() + ');');
										r.push(canvasCtxStr + '.fillStyle = "' + textColourStr + '";');
										r.push(canvasCtxStr + '.fillText("' + symbCell + '", ' + (cellX + cellTextX).toString() + ', ' + (cellY + cellTextY).toString() + ');');
									}
								}
								r.push('</script>');
							}

							var turnIndex = -1;
							var turnStr   = '';

							r.push('<p>' + getTranslationByName("bonusGame", translations).toUpperCase() + '</p>');

							/////////////////////
							// Bonus Functions //
							/////////////////////
							function showBonusTotal(A_arrPrizes, A_arrPrizeNames, A_iMulti)
							{
								var bCurrSymbAtFront = false;
								var iBonusTotal 	 = 0;
								var iPrize      	 = 0;
								var iPrizeTotal 	 = 0;
								var strCurrSymb      = '';
								var strDecSymb  	 = '';
								var strThouSymb      = '';
								var strPrize      	 = '';

								function getCurrencyInfoFromTopPrize()
								{
									var topPrize               = convertedPrizeValues[0];
									var strPrizeAsDigits       = topPrize.replace(new RegExp('[^0-9]', 'g'), '');
									var iPosFirstDigit         = topPrize.indexOf(strPrizeAsDigits[0]);
									var iPosLastDigit          = topPrize.lastIndexOf(strPrizeAsDigits.substr(-1));
									bCurrSymbAtFront           = (iPosFirstDigit != 0);
									strCurrSymb 	           = (bCurrSymbAtFront) ? topPrize.substr(0,iPosFirstDigit) : topPrize.substr(iPosLastDigit+1);
									var strPrizeNoCurrency     = topPrize.replace(new RegExp('[' + strCurrSymb + ']', 'g'), '');
									var strPrizeNoDigitsOrCurr = strPrizeNoCurrency.replace(new RegExp('[0-9]', 'g'), '');
									strDecSymb                 = strPrizeNoDigitsOrCurr.substr(-1);
									strThouSymb                = (strPrizeNoDigitsOrCurr.length > 1) ? strPrizeNoDigitsOrCurr[0] : strThouSymb;
								}

								function getPrizeInCents(AA_strPrize)
								{
									return parseInt(AA_strPrize.replace(new RegExp('[^0-9]', 'g'), ''), 10);
								}

								function getCentsInCurr(AA_iPrize)
								{
									var strValue = AA_iPrize.toString();

									strValue = (strValue.length < 3) ? ('00' + strValue).substr(-3) : strValue;
									strValue = strValue.substr(0,strValue.length-2) + strDecSymb + strValue.substr(-2);
									strValue = (strValue.length > 6) ? strValue.substr(0,strValue.length-6) + strThouSymb + strValue.substr(-6) : strValue;
									strValue = (bCurrSymbAtFront) ? strCurrSymb + strValue : strValue + strCurrSymb;

									return strValue;
								}

								getCurrencyInfoFromTopPrize();

								r.push('<p>' + getTranslationByName("bonusWin", translations) + ' : ' + '</p>');

								r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
								r.push('<tr class="tablehead">');
								r.push('<td>(</td>');

								for (prizeIndex = 0; prizeIndex < A_arrPrizes.length; prizeIndex++)
								{
									strPrize = A_arrPrizes[prizeIndex];
									iPrize = getPrizeInCents(strPrize);
									iPrizeTotal += iPrize;
									 
									symbDesc      = A_arrPrizeNames[prizeIndex];
									canvasIdStr   = 'cvsBonusWinSummarySymb' + symbDesc;
									elementStr    = 'keyBonusWinSummarySymb' + symbDesc;
									isPrizeCell   = (symbBonusPrizes.indexOf(symbDesc) != -1);
									boxColourStr  = (isPrizeCell) ? bonusBoxColours[symbBonusPrizes.indexOf(symbDesc)] : bonusSBoxColours[symbBonusWins.indexOf(symbDesc)];
									textColourStr = (isPrizeCell) ? colourBlack : bonusSTextColours[symbBonusWins.indexOf(symbDesc)];

									r.push('<td align="center">');
									showSymb(canvasIdStr, elementStr, boxColourStr, textColourStr, symbDesc);
									r.push('</td>');

									r.push('<td>');
									r.push(strPrize);
									if (prizeIndex != A_arrPrizes.length -1)
									{
 										r.push(' + ');
										r.push('</td>');
									}
								}

								r.push(')' + '</td>'); 
								symbDesc      = 'X';
								canvasIdStr   = 'cvsBonusWinSummarySymb' + symbDesc;
								elementStr    = 'keyBonusWinSummarySymb' + symbDesc;
								boxColourStr  = bonusSBoxColours[symbBonusWins.indexOf(symbDesc)];
								textColourStr = bonusSTextColours[symbBonusWins.indexOf(symbDesc)];

								r.push('<td align="center">');
								showSymb(canvasIdStr, elementStr, boxColourStr, textColourStr, symbDesc);
								r.push('</td>');

								r.push('<td> ' + A_iMulti.toString() + '</td>');

								iBonusTotal = iPrizeTotal * A_iMulti;

								r.push('<td> = ' + getCentsInCurr(iPrizeTotal) + ' x ' + A_iMulti.toString() + ' = ' + getCentsInCurr(iBonusTotal) + '</td>');
								r.push('</tr>');
								r.push('</table>');
							}

							///////////////////////
							// Bonus Symbols Key //
							///////////////////////
							r.push('<div style="float:left; margin-right:50px">');
							r.push('<p>' + getTranslationByName("titleBonusSymbolsKey", translations) + '</p>');

							r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
							r.push('<tr class="tablehead">');
							r.push('<td>' + getTranslationByName("keySymbol", translations) + '</td>');
							r.push('<td>' + getTranslationByName("keyDescription", translations) + '</td>');
							r.push('</tr>');

							for (var bonusIndex = 0; bonusIndex < symbBonusPrizes.length; bonusIndex++)
							{
								symbBonus     = symbBonusPrizes[bonusIndex];
								canvasIdStr   = 'cvsBonusKeySymb' + symbBonus;
								elementStr    = 'keyBonusSymb' + symbBonus;
								boxColourStr  = bonusBoxColours[bonusIndex];
								symbDesc      = 'symbBonus' + symbBonus;

								r.push('<tr class="tablebody">');
								r.push('<td align="center">');

								showSymb(canvasIdStr, elementStr, boxColourStr, colourBlack, symbBonus);

								r.push('</td>');
								r.push('<td>' + getTranslationByName(symbDesc, translations) + '</td>');
								r.push('</tr>');
							}
							r.push('</table>');
							r.push('</div>');

							/////////////////////////
							// Special Symbols Key //
							/////////////////////////
							r.push('<div style="float:left; margin-right:50px">');
							r.push('<p>' + getTranslationByName("titleSpecialSymbolsKey", translations) + '</p>');

							r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
							r.push('<tr class="tablehead">');
							r.push('<td>' + getTranslationByName("keySymbol", translations) + '</td>');
							r.push('<td>' + getTranslationByName("keyDescription", translations) + '</td>');
							r.push('</tr>');

							for (var specialIndex = 0; specialIndex < symbBonusWins.length; specialIndex++)
							{
								symbSpecial   = symbBonusWins[specialIndex];
								canvasIdStr   = 'cvsBonusKeySymb' + symbSpecial;
								elementStr    = 'keyBonusSymb' + symbSpecial;
								boxColourStr  = bonusSBoxColours[specialIndex];
								textColourStr = bonusSTextColours[specialIndex];
								symbDesc      = 'symbBonus' + symbSpecial;

								r.push('<tr class="tablebody">');
								r.push('<td align="center">');

								showSymb(canvasIdStr, elementStr, boxColourStr, textColourStr, symbSpecial);

								r.push('</td>');
								r.push('<td>' + getTranslationByName(symbDesc, translations) + '</td>');
								r.push('</tr>');
							}

							r.push('</table>');
							r.push('</div>');

							////////////////////////////
							// Additional Symbols Key //
							////////////////////////////
							r.push('<div style="float:left; margin-right:50px">');
							r.push('<p>' + getTranslationByName("titleAddtionalSymbolsKey", translations) + '</p>');

							r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
							r.push('<tr class="tablehead">');
							r.push('<td>' + getTranslationByName("keySymbol", translations) + '</td>');
							r.push('<td>' + getTranslationByName("keyDescription", translations) + '</td>');
							r.push('</tr>');

							canvasIdStr   = 'cvsBonusASKeySymbT';
							elementStr    = 'keyBonusASSymbT';
							r.push('<tr class="tablebody">');
							r.push('<td align="center">');

							showSymb(canvasIdStr, elementStr, colourBlack, colourWhite, "T");

							r.push('</td>');
							r.push('<td>' + getTranslationByName("turn", translations) + '</td>');
							r.push('</tr>');

							canvasIdStr   = 'cvsBonusASKeySymbS';
							elementStr    = 'keyBonusASSymbS';
							r.push('<tr class="tablebody">');
							r.push('<td align="center">');

							showSymb(canvasIdStr, elementStr, colourBlack, colourWhite, "S");
							
							r.push('</td>');
							r.push('<td>' + getTranslationByName("symbol", translations) + '</td>');
							r.push('</tr>');

							r.push('</table>');
							r.push('</div>');

							r.push('<div style="clear:both">');
							r.push('<br>');

							/////////////////
							// Bonus Turns //
							/////////////////
							var bonusPrizes			= [];
							var bonusPrizeNames		= [];
							const bonusLetterNames	= ["A","B","C","D","E","F","1","2","3","X"];
							var bonusLetterCounts 	= [0,0,0,0,0,0,0,0,0,1];
							var bonusSymb		  	= '';
							var colUpdated 		  	= -1;
							var lastRow 		  	= false;

							r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');

							// Bonus Table Headings Row
							r.push('<tr>');
							canvasIdStr = 'cvsBonusGridHeaderA' + pad(1, 2);
							elementStr  = 'phaseBonusGridHeaderA' + pad(1, 2);
							r.push('<td></td>');
							canvasIdStr = 'cvsBonusGridHeaderA' + pad(2, 2);
							elementStr  = 'phaseBonusGridHeaderA' + pad(2, 2);
							r.push('<td></td>');

							for (var i = 0; i < bonusLetterNames.length; i++)
							{
								symbDesc = bonusLetterNames[i];
								isPrizeCell = (symbBonusPrizes.indexOf(symbDesc) != -1);
								boxColourStr = (isPrizeCell) ? bonusBoxColours[symbBonusPrizes.indexOf(symbDesc)] : bonusSBoxColours[symbBonusWins.indexOf(symbDesc)];
								textColourStr = (isPrizeCell) ? colourBlack : bonusSTextColours[symbBonusWins.indexOf(symbDesc)];
								canvasIdStr = 'cvsBonusGridHeaderA' + bonusLetterNames[i];
								elementStr  = 'phaseBonusGridHeaderA' + bonusLetterNames[i];
								r.push('<td>');
								showSymb(canvasIdStr, elementStr, boxColourStr, textColourStr, bonusLetterNames[i]);
								r.push('</td>');
							}
							r.push('</tr>');

							// Bonus Table Base Values Row
							r.push('<tr>');
							symbDesc = "T"; 
							canvasIdStr = 'cvsBonusGridStart' + symbDesc;
							elementStr  = 'phaseBonusGridStart' + symbDesc;
							r.push('<td>');
							showSymb(canvasIdStr, elementStr, colourBlack, colourWhite, symbDesc);
							r.push('</td>');
							
							symbDesc = "S";
							canvasIdStr = 'cvsBonusGridStart' + symbDesc;
							elementStr  = 'phaseBonusGridStart' + symbDesc;
							r.push('<td>');
							showSymb(canvasIdStr, elementStr, colourBlack, colourWhite, symbDesc);
							r.push('</td>');

							for (var i = 0; i < bonusLetterCounts.length; i++)
							{
								symbDesc = bonusLetterCounts[i].toString();
								canvasIdStr = 'cvsBonusGridStart' + i.toString() + symbDesc;
								elementStr  = 'phaseBonusGridStart' + i.toString() + symbDesc;
								r.push('<td>');
								showSymb(canvasIdStr, elementStr, colourWhite, colourBlack, symbDesc);
								r.push('</td>');
							}
							r.push('</tr>');

							// Bonus Table Values Rows
							for (var turnIndex = 0; turnIndex < scenarioBonus.length; turnIndex++)
							{
								// Bonus Table Figure out display value (A-F, 1-3, X, W)
								bonusSymb = scenarioBonus[turnIndex];
								if (bonusSymb == "1" || bonusSymb == "2" || bonusSymb == "3")
								{
									bonusLetterCounts[5 + parseInt(bonusSymb, 10)]++;
									colUpdated = 5 + parseInt(bonusSymb, 10);
								}
								else if (bonusSymb == "W")
								{
									for (var i = 0; i < 6; i++)
									{
										bonusLetterCounts[i]++;
									}
									colUpdated = -1;
								}
								else if (bonusSymb == "X") 
								{
									bonusLetterCounts[bonusLetterCounts.length -1]++;
									colUpdated = 9;
								}
								else
								{
									bonusLetterCounts[bonusSymb.charCodeAt(0) - 65]++;
									colUpdated = bonusSymb.charCodeAt(0) - 65;
								}

								// Bonus Table Details
								r.push('<tr>');
								symbDesc = (turnIndex + 1).toString();
								canvasIdStr = 'cvsBonusGrid' + pad(turnIndex, 2) + symbDesc;
								elementStr  = 'phaseBonusGrid' + pad(turnIndex, 2) + symbDesc;
								r.push('<td>');
								showSymb(canvasIdStr, elementStr, colourWhite, colourBlack, symbDesc);
								r.push('</td>');

								symbDesc = bonusSymb;
								isPrizeCell = (symbBonusPrizes.indexOf(symbDesc) != -1);
								canvasIdStr = 'cvsBonusGridA' + pad(turnIndex, 2) + symbDesc;
								elementStr  = 'phaseBonusGridA' + pad(turnIndex, 2) + symbDesc;
								boxColourStr = (isPrizeCell) ? bonusBoxColours[symbBonusPrizes.indexOf(symbDesc)] : bonusSBoxColours[symbBonusWins.indexOf(symbDesc)];
								textColourStr = (isPrizeCell) ? colourBlack : bonusSTextColours[symbBonusWins.indexOf(symbDesc)];
								r.push('<td>');
								showSymb(canvasIdStr, elementStr, boxColourStr, textColourStr, symbDesc);
								r.push('</td>');

								for (var i = 0; i < bonusLetterCounts.length; i++)
								{
									symbDesc = bonusLetterCounts[i].toString();
									canvasIdStr = 'cvsBonusGridB' + pad(turnIndex, 2) + i.toString() + symbDesc;
									elementStr  = 'phaseBonusGridB' + pad(turnIndex, 2) + i.toString() + symbDesc;
									lastRow = (turnIndex == (scenarioBonus.length -1));
									r.push('<td>');
									if (lastRow) 
									{
										boxColourStr = ((i < 6) && (parseInt(symbDesc) == 3)) ? colourYellow : (((i > 5) && (i < 9) && (parseInt(symbDesc) == 1)) ? colourYellow : colourWhite);
									}
									else
									{
										boxColourStr = (i == colUpdated) ? colourMidGreen : colourWhite;
									}
									showSymb(canvasIdStr, elementStr, boxColourStr, colourBlack, symbDesc);
									r.push('</td>');
								}
								r.push('</tr>');
							}
							r.push('</table>');
							r.push('</div>');

							//////////////////
							// Bonus Prizes //
							//////////////////
							var bonusPrizeData = '';
							for (var i = 0; i < 6; i++)
							{
								if (bonusLetterCounts[i] == 3)
								{	
									bonusPrizeData = String.fromCharCode(65 + i);
									bonusPrizes.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, 'B' + bonusPrizeData)]);
									bonusPrizeNames.push(bonusPrizeData);
								}
							}
							for (var i = 6; i < bonusLetterCounts.length -1; i++)
							{
								if (bonusLetterCounts[i] > 0)
								{	
									bonusPrizeData = (i - 5).toString();
									bonusPrizes.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, 'I' + bonusPrizeData)]);
									bonusPrizeNames.push(bonusPrizeData);
								}
							}
							r.push('<p>&nbsp;</p>');
							showBonusTotal(bonusPrizes, bonusPrizeNames, bonusLetterCounts[9]);
						}

						r.push('<p>&nbsp;</p>');

						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
	 						{
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
 								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
 								r.push('</td>');
 								r.push('</tr>');
							}
							r.push('</table>');
						}
						return r.join('');
					}

					function getScenario(jsonContext)
					{
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}

					function getMainGameData(scenario)
					{
						return scenario.split("|")[0];
					}

					function getBonusData(scenario)
					{
						var scenarioData = scenario.split("|")[1];

						if (scenarioData != '')
						{
							return scenarioData;
						}

						return "";
					}

					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeStructures, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeStructStrings = prizeStructures.split("|");

						for(var i = 0; i < pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeStructStrings[i];
							}
						}
						return "";
					}

					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;
						return pricePoint;
					}

					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{
						for(var i = 0; i < prizeNames.length; ++i)
						{
							if(prizeNames[i] == currPrize)
							{
								return i;
							}
						}
					}

					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}

					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}

					// Grab Wager Type
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function getType(jsonContext, translations)
					{
						// Parse json and retrieve wagerType string.
						var jsObj = JSON.parse(jsonContext);
						var wagerType = jsObj.wagerType;

						return getTranslationByName(wagerType, translations);
					}
				]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='wagerType']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="my-ext:getType($odeResponseJson, $translations)" disable-output-escaping="yes" />
						</td>
					</tr>
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<br />			
				
				<x:variable name="convertedPrizeValues">
					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>


				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
