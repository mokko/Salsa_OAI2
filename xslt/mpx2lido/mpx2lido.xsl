<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:lido="http://www.lido-schema.org"
	xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

	<!--
		This transformation is supposed to convert mpx to valid lido as used by mimo.

		QUESTION: Which version of LIDO to use?
		Currently MIMO uses lido 0.7 while the athena website names
		version 0.8 as the current version.

		HISTORY
		v.004 October 3, 2010
		Check where we are:
		resulting xml validates as LIDO 0.9
		lidoRecID rectified to use colon, use type="local"
		lido:classification/lido:term has mpx:titel, mpx:sachbegriff, mpx:SystematikArt
		lido:classification/lido:term DOES NOT HAVE mpx:identNr


		v.003 September 2, 2010
		converted to XSLT 1.0 for Salsa OAI, resp. XML::LibXSLT

		v.002 May 10,2010
		-correct values in skeleton mapping (lido:titleSet)

		v.001 May 09, 2010
		-create skeleton lido doc so that it validates

		TODO:
		obj835417 is Trommelschlegel i.e. Teil von Musikinstrument. Wie soll man das erkennen?
	-->


	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />


	<xsl:template match="/">
		<lido:lidoWrap
			xsi:schemaLocation="http://www.lido-schema.org  http://www.lido-schema.org/schema/v0.9/lido-v0.9.xsd">

			<xsl:apply-templates
				select="/mpx:museumPlusExport/mpx:sammlungsobjekt" />
		</lido:lidoWrap>
	</xsl:template>

	<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
		<xsl:variable name="currentId" select="@objId" />
		<!--xsl:message>
			<xsl:value-of select="concat ('objId',$currentId)"/>
			</xsl:message-->
		<lido:lido>
			<lido:lidoRecID lido:type="local">
				spk:obj-
				<xsl:value-of select="@objId" />
			</lido:lidoRecID>
			<lido:descriptiveMetadata xml:lang="de">
				<lido:objectClassificationWrap>
					<lido:objectWorkTypeWrap>
						<lido:objectWorkType>
							<lido:term>
								<xsl:value-of
									select="child::mpx:objekttyp" />
							</lido:term>
						</lido:objectWorkType>
					</lido:objectWorkTypeWrap>

					<xsl:if
						test="child::mpx:titel or child::mpx:sachbegriff or child::mpx:systematikArt">
						<lido:classificationWrap>
							<xsl:for-each select="child::mpx:titel">
								<lido:classification>
									<lido:term xml:lang="de">
										<xsl:value-of select="." />
									</lido:term>
								</lido:classification>
							</xsl:for-each>
							<xsl:for-each
								select="child::mpx:sachbegriff">
								<lido:classification>
									<lido:term xml:lang="de">
										<xsl:value-of select="." />
									</lido:term>
								</lido:classification>
							</xsl:for-each>
							<xsl:if test="child::mpx:systematikArt">
								<lido:classification>
									<lido:term xml:lang="de">
										<xsl:value-of select="." />
									</lido:term>
								</lido:classification>
							</xsl:if>
						</lido:classificationWrap>
					</xsl:if>
				</lido:objectClassificationWrap>
				<lido:objectIdentificationWrap>
					<!--
						Should we involve sachbegriff and titel ? I guess so, but how exactly
						According to lido-v0.7.xsd titleSet is repeatable, MIMO D2.1 is contradicting itself
						TODO: Currently, I put all mpx:sachbegriff and mpx:titel. Probably not good.
					-->
					<!--xsl:value-of select="'DEBUG:mpx:sachbegriff exists'"/-->
					<lido:titleWrap>

						<xsl:choose>
							<xsl:when test="child::mpx:titel">
								<xsl:for-each
									select="child::mpx:titel">
									<lido:titleSet>
										<lido:appellationValue>
											<xsl:value-of select="." />
										</lido:appellationValue>
									</lido:titleSet>
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="child::mpx:sachbegriff">
								<xsl:for-each
									select="child::mpx:sachbegriff">
									<lido:titleSet>
										<lido:appellationValue>
											<xsl:value-of select="." />
										</lido:appellationValue>
									</lido:titleSet>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<!-- otherwise: If neither mpx:titel or mpx:sachbegriff, write nothing & create a non-validating lido so we can find the error easily-->
								<lido:titleSet>
									<lido:appellationValue>
										kein Titel
									</lido:appellationValue>
								</lido:titleSet>
							</xsl:otherwise>
						</xsl:choose>
					</lido:titleWrap>
					<lido:repositoryWrap>
						<lido:repositorySet
							lido:repositoryType="current">
							<!-- Kriegsverluste waeren vielleicht nicht current , MIMO-SPK hat aber nur current repositories. Ebenso bei der fehlenden Block-Sammlung -->
							<lido:repositoryName>
								<lido:legalBodyName>
									<lido:appellationValue>
										<!-- Soll hier mpx:credit verwendet werden? -->
										<xsl:value-of
											select="child::verwaltendeInstitution" />
									</lido:appellationValue>
								</lido:legalBodyName>
							</lido:repositoryName>
							<!-- was tun mit mehrfachen identNr und alten Nr?-->
							<lido:workID lido:type="inventory number">
								<xsl:value-of
									select="child::mpx:identNr" />
							</lido:workID>
						</lido:repositorySet>
					</lido:repositoryWrap>
				</lido:objectIdentificationWrap>
			</lido:descriptiveMetadata>
			<lido:administrativeMetadata xml:lang="de">
				<lido:rightsWorkWrap>
					<lido:rightsWorkSet>
						<lido:rightsType xml:lang="en">
							to be specified
						</lido:rightsType>
						<lido:rightsHolder>
							<lido:legalBodyName>
								<!-- Sollte hier ein mpx-Feld verwendet werden? -->
								<lido:appellationValue xml:lang="de">
									Staatliche Museen zu Berlin,
									Stiftung Preussischer Kulturbesitz
								</lido:appellationValue>
							</lido:legalBodyName>
						</lido:rightsHolder>
					</lido:rightsWorkSet>
				</lido:rightsWorkWrap>
				<lido:recordWrap>
					<lido:recordID lido:type="item">
						<xsl:value-of select="@objId" />
					</lido:recordID>

					<!-- before we had <lido:recordType/> -->
					<lido:recordType xml:lang="en">
						item
					</lido:recordType>

					<lido:recordSource>
						<lido:legalBodyName>
							<lido:appellationValue>
								<xsl:value-of
									select="child::mpx:verwaltendeInstitution" />
							</lido:appellationValue>
						</lido:legalBodyName>
					</lido:recordSource>
				</lido:recordWrap>
				<lido:resourceWrap>
					<xsl:for-each
						select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt=$currentId]">

						<lido:resourceSet>
							<!--
								we need a media server before we can deliver the url, in the meantime we can put the local URI
								in the meantime MIMO has set up an ftp server and we just need to upload stuff

							-->
							<lido:linkResource>
								<xsl:value-of
									select="mpx:multimediaPfadangabe" />
								<xsl:choose>
									<!-- match internal MuseumPlus paths -->
									<xsl:when
										test="contains (mpx:multimediaPfadangabe, ':\')">
										<xsl:value-of select="'\'" />
									</xsl:when>
									<!-- assume forward slash for urls -->
									<xsl:otherwise>
										<xsl:value-of select="'/'" />
									</xsl:otherwise>
								</xsl:choose>
								<xsl:value-of
									select="mpx:concat(mpx:multimediaDateiname,'.',mpx:multimediaErweiterung)" />
							</lido:linkResource>
							<lido:resourceID lido:pref="preferred"
								lido:type="local">
								<xsl:value-of select="@mulId" />
							</lido:resourceID>
							<!--
								at this time I don't know how to differenciate between image resources and others, probably there is a mume field
								xml:lang="en" not supported in resourceType in LIDO 0.9, but specified in example from Paris
								http://194.250.19.133/scripts/oaiserver_lido.asp?verb=getrecord&set=MU&metadataprefix=lido&identifier=0156624
							-->
							<lido:resourceType>
								<lido:term xml:lang="en">
									image
								</lido:term>
							</lido:resourceType>
							<lido:rightsResource>
								<lido:rightsType>
									Alle Rechte vorbehalten.
								</lido:rightsType>
							</lido:rightsResource>
							<lido:rightsResource>
								<lido:creditLine>
									<xsl:value-of
										select="mpx:multimediaUrhebFotograf" />
								</lido:creditLine>
							</lido:rightsResource>
							<!-- TODO: I am not at all sure we have such a field. Maybe we can make one by adding various fields  -->
							<lido:resourceViewDescription>
								Harpe arquée "kundi", anonyme, vers
								1920, E.999.10.1, vue de face -
								Jean-Marc Anglès
							</lido:resourceViewDescription>
						</lido:resourceSet>
					</xsl:for-each>
				</lido:resourceWrap>
			</lido:administrativeMetadata>
		</lido:lido>
	</xsl:template>
</xsl:stylesheet>
