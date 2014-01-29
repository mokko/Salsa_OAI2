<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="mpx" version="2.0"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- this is working xslt2 version that filters out mume doubles (dubletten)

DF: a mume doublette is the case where more than one mume records describe 
		the same file (image) redundantly. Occasionally, the same image is supposed 
		to be used for two different objects, such as a drum and its mallet. So this 
		case is not a doublette. 

-->


	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/">
		<xsl:copy>
			<xsl:apply-templates select="/mpx:museumPlusExport" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/mpx:museumPlusExport">
		<xsl:copy>
			<xsl:for-each-group select="/mpx:museumPlusExport/mpx:multimediaobjekt"
				group-by="mpx:verknüpftesObjekt">

				<xsl:variable name="vObj" select="mpx:verknüpftesObjekt" />

				<xsl:for-each-group select="current-group()"
					group-by="mpx:multimediaDateiname">
					<xsl:sort select="mpx:verknüpftesObjekt" data-type="number" />
					<xsl:sort select="mpx:multimediaDateiname" data-type="text"/>
					<xsl:sort select="@quelle" />

					<xsl:variable name="dname" select="mpx:multimediaDateiname" />

					<!-- xsl:message> <xsl:text>&#xa;</xsl:text> <xsl:value-of select="'dname:',$dname" 
						/> </xsl:message -->


					<xsl:choose>
						<xsl:when test="count(current-group()) = 1">

							<!-- xsl:text>&#xa;</xsl:text> <xsl:comment> <xsl:text>only 1 mume 
								with this vObj and dname</xsl:text> </xsl:comment> <xsl:text>&#xa;</xsl:text -->

							<xsl:copy-of select="current-group()" />
						</xsl:when>
						<xsl:otherwise>
							<!-- xsl:text>&#xa;</xsl:text> <xsl:comment> <xsl:value-of select="' 
								1+ mume with this vObj and dname:', 'count vs mpx-rif:', count(current-group()), 
								count(@quelle='mpx-rif')" /> </xsl:comment> <xsl:text>&#xa;</xsl:text -->
							<xsl:message>
								<xsl:value-of
									select="'   1+ mume with this vObj and dname:', 
								'count vs mpx-rif:',
								count(current-group()),
								count(@quelle='mpx-rif')" />
							</xsl:message>
							<!-- We need all fake mume if there are only fake ones. We need all 
								real mume if there are only real ones. We only want to discard mume if there 
								is a real one for the same file. -->
							<xsl:choose>
								<xsl:when test="count(@quelle='mpx-rif') eq 0">
									<xsl:message>
										<xsl:text>NONE of the mume with this vObj and dname are faked</xsl:text>
									</xsl:message>
									<!-- xsl:text>&#xa;</xsl:text> <xsl:comment> <xsl:text>NONE of the 
										mume with this vObj and dname are faked</xsl:text> </xsl:comment> <xsl:text>&#xa;</xsl:text -->

									<xsl:copy-of select="current-group()" />

								</xsl:when>
								<xsl:when test="count(current-group())-count(@quelle='mpx-rif') eq 0">
									<xsl:message>
										<xsl:text>ALL mume with this vObj and dname are fake</xsl:text>
									</xsl:message>
									<!-- xsl:text>&#xa;</xsl:text> <xsl:comment> <xsl:text>ALL mume 
										with this vObj and dname are fake</xsl:text> </xsl:comment> <xsl:text>&#xa;</xsl:text -->

									<xsl:copy-of select="current-group()" />
								</xsl:when>

								<xsl:when test="count(current-group()) - count(@quelle='mpx-rif')> 0">
									<xsl:message>
										<xsl:value-of
											select="'this group of mume with this vObj and dname is MIXED:',
									$vObj, $dname,count(current-group()[not(@quelle)])" />
									</xsl:message>
									<!-- xsl:text>&#xa;</xsl:text> <xsl:comment> <xsl:value-of select="'this 
										group of mume with this vObj and dname is MIXED:', $vObj, $dname,count(current-group()[not(@quelle)])" 
										/> </xsl:comment> <xsl:text>&#xa;</xsl:text -->
									<xsl:copy-of select="current-group()[not(@quelle)]" />
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each-group>
			</xsl:for-each-group>

			<xsl:copy-of select="/mpx:museumPlusExport/mpx:personKörperschaft" />
			<xsl:copy-of select="/mpx:museumPlusExport/mpx:sammlungsobjekt" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
