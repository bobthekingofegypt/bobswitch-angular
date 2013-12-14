describe('angularjs homepage', function() {
  it('should greet the named user', function() {
    browser.get('http://127.0.0.1:4999/#/github');

    element(by.model('message')).sendKeys('Julie');


  });
});
