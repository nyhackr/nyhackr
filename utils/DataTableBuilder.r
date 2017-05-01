makeDatatable <- function(data, 
                          extensions='Scroller',
                          dom="tS",
                          escape=FALSE,
                          colsToHide=NA, class='display',
                          order=list(list(0, 'desc')),
                          scrollY=400, scrollX=TRUE, scrollCollapse=TRUE,
                          height=NULL, width=NULL,
                          columnsWidth='50px', colsToFixWidth=NA,
                          elementID=NULL)
{
    colsToNums <- which(names(data$data()) %in% colsToHide) - 1
    colsToFixWidthNums <- which(names(data$data()) %in% colsToFixWidth) - 1
    # hideList <- if(is.na(data)) {list()} else {list(list(visible=FALSE, targets=colsToHide))}
    
    DT::datatable(data,
                  escape=escape,
                  rownames=FALSE,
                  height=height, width=width,
                  class=class,
                  extensions=extensions,
                  # filter='top',
                  options=list(
                      dom=dom,
                      autoWidth=TRUE,
                      columnDefs=list(
                          list(visible=FALSE, targets=colsToNums),
                          list(width=columnsWidth, targets=colsToFixWidthNums)),
                      order=order,
                      scrollX=scrollX,
                      scrollY=scrollY,
                      scrollCollapse=scrollCollapse,
                      scroller=TRUE,
                      colReorder=TRUE,
                      keys=TRUE
                  ), 
                  elementId=elementID
    )
}