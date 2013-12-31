describe('player joining', function() {
    var browser2, element2, by2;

    var signInOnBrowserOne = function() {
        var joinButton = browser.element(by.css('[value="Join"]'));
        joinButton.click();

        element(by.model('input.name')).sendKeys('Bob');
        browser.element(by.css('[value="OK"]')).click();
    };

    var signInOnBrowserTwo = function() {
        var joinButton = browser2.element(by2.css('[value="Join"]'));
        joinButton.click();

        element2(by2.model('input.name')).sendKeys('John');
        browser2.element(by.css('[value="OK"]')).click();
    };

    beforeEach(function() {
        browser2 = protractors[1].browser;
        element2 = protractors[1].element;
        by2 = protractors[1].by;

        browser.get('http://127.0.0.1:4999/#/github');
        browser2.get('http://127.0.0.1:4999/#/github');
    });

    it('should have no players on startup', function() {
        var playerList = element.all(by.repeater('player in players'));
        expect(playerList.count()).toBe(0);
        var playerListOther = element2.all(by2.repeater('player in players'));
        expect(playerListOther.count()).toBe(0);
    });

    it('should add player to both browsers on signin', function() {
        signInOnBrowserOne();

        var playerList = element.all(by.repeater('player in players'));
        expect(playerList.count()).toBe(1);

        var playerListOther = element2.all(by2.repeater('player in players'));
        expect(playerListOther.count()).toBe(1);
    });

    it('should add player to each browsers on signin', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        var playerList = element.all(by.repeater('player in players'));
        expect(playerList.count()).toBe(2);

        var playerListOther = element2.all(by2.repeater('player in players'));
        expect(playerListOther.count()).toBe(2);
    });

    it('should contain one chat message on start', function() {
        var chatList = element.all(by.repeater('message in messages'));
        expect(chatList.count()).toBe(1);

        var chatList2 = element2.all(by2.repeater('message in messages'));
        expect(chatList2.count()).toBe(1);
    });

    it('should show chat message in each browsers after signon', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        element(by.model('message')).sendKeys('WOO');
        browser.actions().sendKeys(protractor.Key.ENTER).perform();

        var chatList = element.all(by.repeater('message in messages'));
        expect(chatList.get(1).getText()).toBe('Bob: WOO');
        expect(chatList.count()).toBe(2);

        var chatList2 = element2.all(by2.repeater('message in messages'));
        expect(chatList2.get(1).getText()).toBe('Bob: WOO');
        expect(chatList2.count()).toBe(2);
    });

    it('should show message from second browser', function() {
        signInOnBrowserOne();
        signInOnBrowserTwo();

        element2(by2.model('message')).sendKeys('WOO');
        browser2.actions().sendKeys(protractor.Key.ENTER).perform();

        var chatList = element.all(by.repeater('message in messages'));
        expect(chatList.get(1).getText()).toBe('John: WOO');
        expect(chatList.count()).toBe(2);

        var chatList2 = element2.all(by2.repeater('message in messages'));
        expect(chatList2.get(1).getText()).toBe('John: WOO');
        expect(chatList2.count()).toBe(2);
    });

});
