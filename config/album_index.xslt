<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes"/>

<xsl:param name="resources_dir"/>
<xsl:param name="size_thumb"/>
<xsl:param name="size_full"/>

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
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>

    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="{$resources_dir}/css/album.css" type="text/css"/>
    <link rel="stylesheet" href="{$resources_dir}/galleria/themes/classic/galleria.classic.css" type="text/css"/>
    <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="http://cdnjs.cloudflare.com/ajax/libs/galleria/1.4.2/galleria.min.js"></script>
    <script src="{$resources_dir}/galleria/themes/classic/galleria.classic.min.js"></script>
    <script src="{$resources_dir}/js/album.js"></script>
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

<xsl:template match="body">
  <xsl:element name="body" >
    <xsl:apply-templates select="*"/>
  </xsl:element>
</xsl:template>

<xsl:template match="h1">
  <xsl:variable name="title" select="substring-after(., 'Index of /')"/>
  <nav class="navbar navbar-inverse navbar-fixed-top">
    <div class="navbar-brand">
      <xsl:call-template name="thread">
        <xsl:with-param name="parents" select="''"/>
        <xsl:with-param name="children" select="$title"/>
      </xsl:call-template>
    </div>
  </nav>
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
  <div class="container-fluid">
    <div class="row">
      <div class="col-xs-12 col-sm-3 col-md-2 sidebar">
        <ul class="nav nav-sidebar">
          <xsl:apply-templates select="a" mode="navigation"/>
        </ul>
      </div>
      <div class="col-xs-12 col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
        <div id="galleria">
          <xsl:apply-templates select="a" mode="image"/>
        </div>
        <div id="videos">
          <xsl:apply-templates select="a" mode="video"/>
        </div>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template match="a" mode="image">
  <xsl:variable name="extension" select="translate(substring(@href, string-length(@href) - 3), 'JPEG', 'jpeg')"/>
  <xsl:if test="$extension = '.jpg' or $extension = 'jpeg'">
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="@href"/>?size=<xsl:value-of select="$size_full"/></xsl:attribute>
      <xsl:element name="img">
        <xsl:attribute name="src"><xsl:value-of select="@href"/>?size=<xsl:value-of select="$size_thumb"/></xsl:attribute>
        <xsl:attribute name="data-link"><xsl:value-of select="@href"/></xsl:attribute>
      </xsl:element>
    </xsl:element>
  </xsl:if>
</xsl:template>

<xsl:template match="a" mode="video">
  <xsl:variable name="extension" select="substring(@href, string-length(@href) - 3)"/>
  <xsl:if test="$extension = '.mp4' or $extension = '.3gp'">
    <xsl:element name="video">
      <xsl:attribute name="width">100%</xsl:attribute>
      <xsl:attribute name="controls"/>
      <xsl:attribute name="preload">metadata</xsl:attribute>
      <xsl:attribute name="src"><xsl:value-of select="@href"/></xsl:attribute>
    </xsl:element>
  </xsl:if>
</xsl:template>


<xsl:template match="a" mode="navigation">
  <xsl:variable name="lastchar" select="substring(@href, string-length(@href))"/>
  <xsl:if test="$lastchar = '/'">
    <xsl:element name="li">
      <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
        <xsl:value-of select="."/>
      </xsl:element>
    </xsl:element>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
