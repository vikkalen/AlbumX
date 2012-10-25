<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes"/>

<xsl:template match="@*">
  <xsl:copy />
</xsl:template>

<xsl:template match="*">
  <xsl:element name="{name()}" >
    <xsl:apply-templates select="* | text() | @*"/>
  </xsl:element>
</xsl:template>

<xsl:template match="head">
  <xsl:copy>
    <xsl:apply-templates select="*"/>
    <link rel="stylesheet" href="/resources/css/album.css" type="text/css"/>
    <link rel="stylesheet" href="/resources/galleria/themes/classic/galleria.classic.css" type="text/css"/>
    <script src="/resources/js/jquery-1.8.2.min.js"></script>
    <script src="/resources/galleria/galleria-1.2.8.min.js"></script>
    <script src="/resources/galleria/themes/classic/galleria.classic.min.js"></script>
    <script src="/resources/js/album.js"></script>
  </xsl:copy>
</xsl:template>

<xsl:template match="title">
  <xsl:variable name="title" select="substring-after(., 'Index of /')"/>
  <xsl:variable name="parent" select="substring-before($title, '/')"/>
  <xsl:variable name="children" select="substring-after($title, concat($parent, '/'))"/>
  <title>
      <xsl:value-of select="$parent"/>
      <xsl:text> : </xsl:text>
      <xsl:call-template name="lastfolder">
        <xsl:with-param name="children" select="$children"/>
      </xsl:call-template>
  </title>
</xsl:template>

<xsl:template name="lastfolder">
  <xsl:param name="children"/>
  <xsl:variable name="currentChildren" select="substring-after($children, '/')"/>
  <xsl:choose>
    <xsl:when test="string-length($currentChildren) = 0">
      <xsl:value-of select="substring-before($children, '/')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="lastfolder">
        <xsl:with-param name="children" select="$currentChildren"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="h1">
  <xsl:variable name="title" select="substring-after(., 'Index of /')"/>
  <div id="header">
    <h1>
      <xsl:call-template name="thread">
        <xsl:with-param name="parents" select="''"/>
        <xsl:with-param name="children" select="$title"/>
      </xsl:call-template>
    </h1>
  </div>
</xsl:template>

<xsl:template name="thread">
  <xsl:param name="parents"/>
  <xsl:param name="children"/>
  <xsl:variable name="current" select="substring-before($children, '/')"/>
  <xsl:variable name="currentParents" select="concat($parents, '/', $current)"/>
  <xsl:variable name="currentChildren" select="substring-after($children, '/')"/>
  <xsl:element name="a">
    <xsl:attribute name="href">
      <xsl:value-of select="concat($currentParents, '/')"/>
    </xsl:attribute>
    <xsl:value-of select="$current"/>
  </xsl:element>
  <xsl:if test="string-length($currentChildren) &gt; 1">
    <xsl:text>&gt;</xsl:text>
    <xsl:call-template name="thread">
      <xsl:with-param name="parents" select="$currentParents"/>
      <xsl:with-param name="children" select="$currentChildren"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="hr"/>

<xsl:template match="pre">
  <div id="menu">
    <ul id="navigation">
      <xsl:apply-templates select="a" mode="navigation"/>
    </ul>
  </div>
  <div id="galleria">
    <xsl:apply-templates select="a" mode="image"/>
  </div>
</xsl:template>

<xsl:template match="a" mode="image">
  <xsl:variable name="extension" select="substring(@href, string-length(@href) - 3)"/>
  <xsl:if test="translate($extension, 'JPG', 'jpg') = '.jpg'">
    <a href="{@href}?size=800">
      <img src="{@href}?size=100" data-link="{@href}"/>
    </a>
  </xsl:if>
</xsl:template>


<xsl:template match="a" mode="navigation">
  <xsl:variable name="lastchar" select="substring(@href, string-length(@href))"/>
  <xsl:if test="$lastchar = '/'">
    <li>
      <a href="{@href}">
        <xsl:value-of select="."/>
      </a>
    </li>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
