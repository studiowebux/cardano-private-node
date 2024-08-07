htmx.config.selfRequestsOnly = false;

function deleteElement(element) {
  element.parentElement.removeChild(element);
}

function deleteElementById(elementId) {
  const element = document.getElementById(elementId);
  if (element) {
    element.remove();
  }
}
