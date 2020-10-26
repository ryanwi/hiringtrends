describe HiringTrends::Program do
  before :each do
    @hn = HiringTrends::Program.new
  end

  # describe "#analyze_submission" do
  #   it "should initialize the terms dictionary from gist" do
  #     @hn.initialize_dictionary
  #   end
  # end

  describe "#analyze_submission" do

    it "separates words with slash separators" do
      terms = {
        "Ruby" => {:count => 0, :percentage => 0, :full_term => "Ruby"},
        "Python" => {:count => 0, :percentage => 0, :full_term => "Python"},
        "JavaScript" => {:count => 0, :percentage => 0, :full_term => "JavaScript"}
      }
      comments = [
        {"text" => "This first comment has ruby in it."},
        {"text" => "in this comment is ruby/javascript"}
      ]

      terms = @hn.analyze_submission(terms, comments)

      expect(terms["Ruby"][:count]).to eq(2)
      expect(terms["JavaScript"][:count]).to eq(1)
    end

    it "separates words with comma separators" do
      terms = {
        "Ruby" => {:count => 0, :percentage => 0, :full_term => "Ruby"},
        "Python" => {:count => 0, :percentage => 0, :full_term => "Python"},
        "JavaScript" => {:count => 0, :percentage => 0, :full_term => "JavaScript"}
      }
      comments = [
        {"text" => "This first comment has ruby in it."},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      expect(terms["Ruby"][:count]).to eq(2)
    end

    it "separates words with periods at end of sentence" do
      terms = {"Ruby" => {:count => 0, :percentage => 0, :full_term => "Ruby"}}
      comments = [
        {"text" => "This first comment has ruby."},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      expect(terms["Ruby"][:count]).to eq(2)
    end

    it "is case insensitive" do
      terms = {"Ruby" => {:count => 0, :percentage => 0, :full_term => "Ruby"}}
      comments = [
        {"text" => "This first comment has Ruby in it."},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      expect(terms["Ruby"][:count]).to eq(2)
    end

    it "counts Objective-c" do
      terms = {
        "JavaScript" => {:count => 0, :percentage => 0, :full_term => "JavaScript"},
        "Objective-C" => {:count => 0, :percentage => 0, :full_term => "Objective-C/alias[Objective-C|ObjectiveC|Objective C]"},
        "PHP" => {:count => 0, :percentage => 0, :full_term => "PHP"},
        "Python" => {:count => 0, :percentage => 0, :full_term => "Python"}
      }
      comments = [
        {"text" => "Primary languages are javascript and python, with a history in php and a little bit of Objective-c. I have experience with many of the common client-side frameworks like Backbone, Knockout, etc."},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      expect(terms["Objective-C"][:count]).to eq(1)
    end

    it "ignore quotes" do
      terms = {
        "JavaScript" => {:count => 0, :percentage => 0, :full_term => "JavaScript"},
        "AngularJS" => {:count => 0, :percentage => 0, :full_term => "AngularJS/js[Angular]"},
        "backbone" => {:count => 0, :percentage => 0, :full_term => "backbone/js[backbone]"},
        "node.js" => {:count => 0, :percentage => 0, :full_term => "node.js/js[node]"}
      }
      comments = [
        {"text" => "Javascript  ['angular','backbone','node']"},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      expect(terms["AngularJS"][:count]).to eq(1)
    end

    it "counts multi-word terms" do
      terms = {
        "Visual Basic" => {:count => 0, :percentage => 0, :full_term => "Visual Basic"},
        "Web services" => {:count => 0, :percentage => 0, :full_term => "Web services"},
        "node.js" => {:count => 0, :percentage => 0, :full_term => "node.js/js[node]"}
      }
      comments = [
        {"text" => "Javascript visual basic web services"},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      expect(terms["Visual Basic"][:count]).to eq(1)
    end

    it "counts .net" do
      terms = {
        ".NET" => {:count => 0, :percentage => 0, :full_term => ".NET"}
      }
      comments = [
        {"text" => "Javascript visual basic c web services C#/.NET"},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      expect(terms[".NET"][:count]).to eq(1)
    end

    it "counts RabbitMQ" do
      terms = {
        "RabbitMQ" => {:count => 0, :percentage => 0, :full_term => "RabbitMQ"}
      }
      comments = [
        {"text" => "Shirts.io – Fremont, CA<p>Want a free custom t-shirt? Read on!<p><i>The Company</i><p><a href=\"https://www.shirts.io\" rel=\"nofollow\">https:&#x2F;&#x2F;www.shirts.io</a> is an online fulfillment service that prints, packs, and delivers custom printed t-shirts, posters, and phone cases.<p>Our mission is to empower our customers to start their own merchandising business by offering well-designed online software with world-class production infrastructure.<p>We are headquartered in Silicon Valley with facilities in California, Pennsylvania and Indiana.<p><i>The Role</i><p>We are looking for junior, mid, and senior full-stack web developers and&#x2F;or software developers with all or some of the following.<p><pre><code> Backend skill sets:\\n\\n - Python, Django, PHP, MySQL, Postgresql\\n - Redis or RabbitMQ\\n - Python Image Library or Ghostscript experience\\n\\n Frontend skill sets:\\n\\n - JavaScript, jQuery\\n - Nice to have: AngularJS, NodeJS, Express.js\\n\\n DevOp skill sets:\\n\\n - Heroku or Amazon AWS, Amazon S3\\n - NewRelic or Sentry for error tracking, Loggly for logging\\n\\n Testing&#x2F;QA skill sets:\\n\\n - Continuous Integration\\n - Selenium testing\\n\\n The Benefits\\n\\n - Competitive salary\\n - Newly furnished office\\n - Professional Mac or PC equipment\\n - Catered meals on Fridays\\n</code></pre>\\nInterested in helping us making printing custom apparel and products easy? Email us at info@shirts.io<p>Just interested in your free custom t-shirt? Take a look at our site and implement a project with our API then email info@shirts.io"},
        {"text" => "New York (NYC) Thomson Reuters<p>Worki\\u0010ng on the team that makes Eikon and the underlying platform. You can learn about the group&#x27;s work, mission, and leadership by jumping to 1:45:00 in this video <a href=\"https://www.media-server.com/m/p/moaghpeu\" rel=\"nofollow\">https:&#x2F;&#x2F;www.media-server.com&#x2F;m&#x2F;p&#x2F;moaghpeu</a><p>Jobs in product development, engineer in test, and dev ops.<p>We use: \\n - HTML5&#x2F;JS&#x2F;Angular\\n - Mobile (iOS&#x2F;Android&#x2F;hybrid)\\n - C++\\n - Hadoop&#x2F;HBase\\n - DevOps: Java, puppet, Sensu, RabbitMQ, ElasticSearch<p>Expertise in one of those sets is a big plus, but get in touch if you have interest and I&#x27;ll see if we have a spot that interests you. Happy to grab coffee with anyone to have a casual chat about the possibilities.<p>Contact: Lou Franco lou.franco -at- thomsonreuters.com"},
        {"text" => "XP-Dev.com - Remote - <a href=\"https://xp-dev.com\" rel=\"nofollow\">https:&#x2F;&#x2F;xp-dev.com</a><p>XP-Dev.com does version control and project hosting (in the same market as Github, Bitbucket, etc). Profitable and bootstrapped.<p>Looking for backend and frontend engineers who would like to get their hands dirty in Subversion, Git and Mercurial. You will be working on new features on the platform that may involve work on the whole stack. You will be liaising directly with real users. Deployments are really quick, and you get to see the impact of your work almost immediately.<p>Stack:<p><pre><code> - Nginx, Apache\\n - Java (Core, Wicket, Hibernate)\\n - Python (mainly for scripting)\\n - Linux\\n - AngularJS, JQuery\\n - MySQL\\n - Redis\\n - RabbitMQ\\n - Fabric\\n</code></pre>\\nThere are other products in the pipeline - most of which are akin to xp-dev.com (hosting&#x2F;productivity platforms). So, there is plenty of room to switch products and try out new things: <a href=\"https://deployer.vc\" rel=\"nofollow\">https:&#x2F;&#x2F;deployer.vc</a>, <a href=\"https://zoned.io\" rel=\"nofollow\">https:&#x2F;&#x2F;zoned.io</a> amongst them.<p>What we&#x27;re looking for:<p><pre><code> - Self starters\\n - Sound understanding of programming\\n you don&#x27;t need to be a Java&#x2F;Python&#x2F;JavaScript guru\\n</code></pre>\\nBenefits:<p><pre><code> - No keeping track of holidays\\n - Flexible working hours\\n - Flexible working conditions (see below)\\n</code></pre>\\nPosition location is remote. You&#x27;ll need to factor in working from home or from a shared space near you (all will be paid for).<p>To apply, just drop a short cover email describing yourself and your CV to rs@exentriquesolutions.com"}
      ]

      terms = @hn.analyze_submission(terms, comments)
      expect(terms["RabbitMQ"][:count]).to eq(3)
    end
  end
end
