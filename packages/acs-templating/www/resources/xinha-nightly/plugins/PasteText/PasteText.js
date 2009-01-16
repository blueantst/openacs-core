/* This compressed file is part of Xinha. For uncomressed sources, forum, and bug reports, go to xinha.org */
function PasteText(c){this.editor=c;var a=c.config;var b=this;a.registerButton({id:"pastetext",tooltip:this._lc("Paste as Plain Text"),image:c.imgURL("ed_paste_text.gif","PasteText"),textMode:false,action:function(){b.show()}});a.addToolbarElement("pastetext",["paste","killword"],1)}PasteText._pluginInfo={name:"PasteText",version:"1.2",developer:"Michael Harris",developer_url:"http://www.jonesadvisorygroup.com",c_owner:"Jones Advisory Group",sponsor:"Jones International University",sponsor_url:"http://www.jonesinternational.edu",license:"htmlArea"};PasteText.prototype._lc=function(a){return Xinha._lc(a,"PasteText")};Xinha.Config.prototype.PasteText={showParagraphOption:true,newParagraphDefault:true};PasteText.prototype.onGenerateOnce=function(){var a=PasteText;if(a.loading){return}a.loading=true;Xinha._getback(Xinha.getPluginDir("PasteText")+"/popups/paste_text.html",function(b){a.html=b})};PasteText.prototype._prepareDialog=function(){var a=this;var b=this.editor;var a=this;this.dialog=new Xinha.Dialog(b,PasteText.html,"PasteText",{width:350});this.dialog.getElementById("ok").onclick=function(){a.apply()};this.dialog.getElementById("cancel").onclick=function(){a.dialog.hide()};if(b.config.PasteText.showParagraphOption){this.dialog.getElementById("paragraphOption").style.display=""}if(b.config.PasteText.newParagraphDefault){this.dialog.getElementById("insertParagraphs").checked=true}this.dialog.onresize=function(){this.getElementById("inputArea").style.height=parseInt(this.height,10)-this.getElementById("h1").offsetHeight-this.getElementById("buttons").offsetHeight-parseInt(this.rootElem.style.paddingBottom,10)+"px";this.getElementById("inputArea").style.width=(this.width-2)+"px"}};PasteText.prototype.show=function(){if(!this.dialog){this._prepareDialog()}var a={inputArea:""};this.dialog.show(a);this.dialog.onresize();this.dialog.getElementById("inputArea").focus()};PasteText.prototype.apply=function(){var a=this.dialog.hide();var b=a.inputArea;var c=a.insertParagraphs;b=b.replace(/</g,"&lt;");b=b.replace(/>/g,"&gt;");if(a.insertParagraphs){b=b.replace(/\t/g,"&nbsp;&nbsp;&nbsp;&nbsp;");b=b.replace(/\n/g,"</p><p>");b="<p>"+b+"</p>";if(Xinha.is_ie){this.editor.insertHTML(b)}else{this.editor.execCommand("inserthtml",false,b)}}else{b=b.replace(/\n/g,"<br />");this.editor.insertHTML(b)}};