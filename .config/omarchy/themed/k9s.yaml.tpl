k9s:
  body:
    fgColor: '#{{ foreground_strip }}'
    bgColor: '#{{ background_strip }}'
    logoColor: '#{{ accent_strip }}'
    logoColorMsg: '#{{ foreground_strip }}'
    logoColorInfo: '#{{ accent_strip }}'
    logoColorWarn: '#{{ color11_strip }}'
    logoColorError: '#{{ color9_strip }}'
  help:
    fgColor: '#{{ foreground_strip }}'
    bgColor: '#{{ background_strip }}'
    sectionColor: '#{{ accent_strip }}'
    keyColor: '#{{ accent_strip }}'
    numKeyColor: '#{{ color13_strip }}'
  prompt:
    fgColor: '#{{ foreground_strip }}'
    bgColor: '#{{ background_strip }}'
    suggestColor: '#{{ color11_strip }}'
    border:
      command: '#{{ accent_strip }}'
      default: '#{{ selection_foreground_strip }}'
  info:
    fgColor: '#{{ foreground_strip }}'
    sectionColor: '#{{ accent_strip }}'
    cpuColor: '#{{ color10_strip }}'
    memColor: '#{{ color14_strip }}'
    k9sRevColor: '#{{ color13_strip }}'
  dialog:
    fgColor: '#{{ foreground_strip }}'
    bgColor: '#{{ background_strip }}'
    buttonFgColor: '#{{ foreground_strip }}'
    buttonBgColor: '#{{ color13_strip }}'
    buttonFocusFgColor: '#{{ color11_strip }}'
    buttonFocusBgColor: '#{{ accent_strip }}'
    labelFgColor: '#{{ color11_strip }}'
    fieldFgColor: '#{{ foreground_strip }}'
  frame:
    border:
      fgColor: '#{{ selection_foreground_strip }}'
      focusColor: '#{{ selection_background_strip }}'
    menu:
      fgColor: '#{{ foreground_strip }}'
      keyColor: '#{{ accent_strip }}'
      numKeyColor: '#{{ accent_strip }}'
    crumbs:
      fgColor: '#{{ selection_foreground_strip }}'
      bgColor: '#{{ selection_background_strip }}'
      activeColor: '#{{ accent_strip }}'
    status:
      newColor: '#{{ color14_strip }}'
      modifyColor: '#{{ color13_strip }}'
      addColor: '#{{ color10_strip }}'
      errorColor: '#{{ color9_strip }}'
      highlightColor: '#{{ color11_strip }}'
      killColor: '#{{ color8_strip }}'
      completedColor: '#{{ color8_strip }}'
    title:
      fgColor: '#{{ foreground_strip }}'
      bgColor: '#{{ background_strip }}'
      highlightColor: '#{{ color11_strip }}'
      counterColor: '#{{ color13_strip }}'
      filterColor: '#{{ accent_strip }}'
  views:
    charts:
      bgColor: '#{{ background_strip }}'
      defaultDialColors:
        - '#{{ color13_strip }}'
        - '#{{ color9_strip }}'
      defaultChartColors:
        - '#{{ color13_strip }}'
        - '#{{ color9_strip }}'
    table:
      fgColor: '#{{ foreground_strip }}'
      bgColor: '#{{ background_strip }}'
      cursorColor: '#{{ selection_background_strip }}'
      header:
        fgColor: '#{{ foreground_strip }}'
        bgColor: '#{{ background_strip }}'
        sorterColor: '#{{ color14_strip }}'
    xray:
      fgColor: '#{{ foreground_strip }}'
      bgColor: '#{{ background_strip }}'
      cursorColor: '#{{ selection_background_strip }}'
      graphicColor: '#{{ color13_strip }}'
      showIcons: false
    yaml:
      keyColor: '#{{ accent_strip }}'
      colonColor: '#{{ color13_strip }}'
      valueColor: '#{{ foreground_strip }}'
    logs:
      fgColor: '#{{ foreground_strip }}'
      bgColor: '#{{ background_strip }}'
      indicator:
        fgColor: '#{{ foreground_strip }}'
        bgColor: '#{{ color13_strip }}'
        toggleOnColor: '#{{ color10_strip }}'
        toggleOffColor: '#{{ color8_strip }}'
