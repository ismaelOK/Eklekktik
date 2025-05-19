import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Infos extends StatelessWidget {
  const Infos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('En savoir plus'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Text(
                          "Nos Valeurs",
                          style:TextStyle(
                            fontFamily: 'MontserratBold',
                            fontSize: 20,
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 5)),
                      Center(
                        child: const Text(
                            "EKLEKTIKK est altruiste et sensible à l'art. Les maître-mots sont solidarité, positivité, proactivité et créativité. Elle s'adresse à des profils entrepreneurs c'est à dire des personnes proactives souhaitant s'investir dans l'acomplissement d'un projet particulier. Des événements solidaires sont organisés afin de fédérer, favoriser les relations intergénérationnelles, stimuler la vie des quartiers et contribuer au bien-être des populations.",
                            textAlign: TextAlign.center,
                            style:TextStyle(
                                fontSize: 15,
                                fontFamily: 'Montserrat'
                            )
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Image.asset("lib/assets/images/eklektikkImg1.PNG"),
                      Padding(padding: EdgeInsets.only(top: 40)),
                      Center(
                        child: Text(
                            "Notre histoire",
                            textAlign: TextAlign.center,
                            style:TextStyle(
                                fontSize: 20,
                                fontFamily: 'MontserratBold'
                            )
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 5)),
                      Text("Marie Grall, présidente de l'association, souhaite transmettre les connaissances et savoirs qu'elle a développés en s'investissant dans 15 entités de culture et social. En effet, elle a exercé en tant que présidente, vice-présidente et trésorière mais aussi comme Déléguée régionale de Force Femmes et d'Entreprendre au Féminin.",
                          textAlign: TextAlign.center,
                          style:TextStyle(
                              fontSize: 15,
                              fontFamily: 'Montserrat'
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Image.asset("lib/assets/images/eklektikkImg2.PNG"),
                      Padding(padding: EdgeInsets.only(top: 40)),
                      Text("Nos partenaires",
                          textAlign: TextAlign.center,
                          style:TextStyle(
                              fontSize: 20,
                              fontFamily: 'MontserratBold'
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 5)),
                      Text("Depuis maintenant 5 ans, des chefs d'entreprise et des bénévoles engagés nous ont rejoint. EKLEKTIKK collabore avec de nombreuses associations comme Bénévoles en action, dont l'activité principale est d'intervenir sur des événements bordelais.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Montserrat'
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Image.asset("lib/assets/images/eklektikkImg3.PNG"),
                      Padding(padding: EdgeInsets.only(top: 40)),
                      Text("Nous contacter",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'MontserratBold'
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 5)),
                      Icon(Icons.location_city),
                      Text("23 Cours du Québec 33300 Bordeaux",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Montserrat'
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Icon(Icons.mail),
                      Text("eklektikk33@gmail.com",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Montserrat'
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Icon(Icons.phone),
                      Text("06 60 16 81 37",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Montserrat'
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 40)),
                      Text("Nous suivre",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'MontserratBold'
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 5)),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () async{
                                  final Uri url = Uri.parse("https://www.facebook.com/people/Eklektikk-Green/pfbid02qpa6kX6Wk4dxAKbsHcXr1vtxkdmC4vvzxLs8mrFKJJFm4iKX2kgtWRY8gWtCwgGal/?fref=search&eid=ARCGW4fgDf8vG4-ileAzOloxvcH48czlDJElEyrU4vXhLpo_yETybnja_s9o1eSd3bIS7VG_-QOr13JG");
                                  if(!await launchUrl(url)){
                                    throw Exception('Could not launch $url');
                                  }
                                },
                                icon: Icon(Icons.facebook)
                            ),
                            IconButton(
                                onPressed: () async{
                                  final Uri url = Uri.parse("https://www.linkedin.com/company/eklektikk/about/");
                                  if(!await launchUrl(url)){
                                    throw Exception('Could not launch $url');
                                  }
                                },
                                icon: FaIcon(
                                    FontAwesomeIcons.linkedin
                                )
                            )
                          ],
                        ),
                      )








                    ]
                )
            )
        )
    );
  }

  launch(String urlFacebook) {}
}
