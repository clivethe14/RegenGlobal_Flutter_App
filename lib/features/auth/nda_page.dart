import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NdaPage extends StatefulWidget {
  final String nextRoute; // where to go after accepting
  const NdaPage({super.key, required this.nextRoute});

  @override
  State<NdaPage> createState() => _NdaPageState();
}

class _NdaPageState extends State<NdaPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NDA Agreement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  // Replace with your actual NDA text
                  '''This Agreement is made and entered into by and between ____________, an entity, located in the city of
        Zip ____________ and/or its affiliates and assigns (hereinafter referred to as “Recipient”), and the GREEN2GOLD
          ENVIRONMENTAL EDUCATION GROUP, located at HAWAII, MAUI and CALIFORNIA and/or its
      affiliates and assigns (hereinafter referred to as “Discloser”). Hereinafter, Discloser and Recipient may be referred
    to in this Agreement collectively as “parties.”
    It is expressly agreed by the parties that this Agreement is not, and shall not be construed as, any form of a “Let
    ter of Intent” or a “Deal Memo” or an agreement to enter into a proposed transaction of any kind. This Agree
    ment is to evidence the parties’ agreement to maintain the confidentiality of the information disclosed by the
    Discloser and shall not constitute any commitment or obligation on the part of the parties to enter into a specific
    contractual agreement of any nature whatsoever. The parties will or already have had discussions and may intend
    to continue having discussions in connection with a possible transaction between them. All such discussions
    referred to above and hereafter will be called the “Discussions.” During and in connection with the Discussions,
        Discloser may disclose information that it regards as confidential. Accordingly, the parties agree as follows:
    1.The information of Discloser which is subject to this Agreement includes, but is not limited to, any informa
        tion relating to ideas, concepts, inventions, discoveries, manufacturing or marketing techniques, know-how,
        processes, formulas, costs, developments, experimental works, works in progress, trade secrets, or any other
        mat
        ters relating to the creations, technical information or business of Discloser; information acquired by Recipient
    from inspection of Discloser’s property; confidential information disclosed to Discloser by third parties; and all
        documents, things and record bearing media disclosing or containing any of the foregoing information, includ
        ing any materials prepared by Recipient which contain or otherwise relate to Discloser’s intellectual, technical,
        and commercial information (all collectively referred to as “Confidential Information”).
    2.Recipient agrees that all Confidential Information obtained from Discloser will be accepted in confidence and
    maintained strictly confidential and shall not, without the prior written consent of Discloser, be disclosed to oth
    ers, copied, photographed, reproduced or transcribed in any, manner whatsoever, in whole or in part.
    3.Recipient agrees that it will not reveal the Confidential Information obtained from Discloser to others, except
    to the extent that it is necessary to disclose such information to its representatives and employees having a need
    to know such information for the sole purpose of evaluating a possible transaction, or carrying out an agreed
    upon activity, between Recipient and Discloser. Recipient further agrees that all such representatives and em
    ployees shall be informed by Recipient of the confidential nature of such information and shall agree to be bound
    by the terms and conditions of this Agreement prior to receiving such information. No other use or disclosure
    of Confidential Information shall be made by Recipient without the prior written consent of Discloser. Recipient
    shall be responsible for compliance by its directors, employees, agents, advisors, affiliates, or subsidiaries with
    the
    provisions of this Agreement. Additionally, Recipient, by entering into this Agreement shall not knowingly cause
    nor instigate a cause to circumvent (i.e., “go around”) Discloser at any time during the respective five (5) year
    period of which the Confidential Information is designated as effective and agreed to between the parties.
    4.Upon Discloser’s request, Recipient agrees to return all Confidential Information and all documents and
    things connected with or related to such information, without retaining any copies. In addition, Recipient agrees
    that all plans, drawings, specifications, ideas, concepts, models, studies, documents, things, or other tangible
    work product produced by Recipient in connection with its use of Discloser’s Confidential Information pursuant
    to this Agreement, whether created by Recipient, its representatives or employees, shall be and remain the property of of Discloser and shall be kept confidential by Recipient subject to the terms of this Agreement.
    5.Recipient agrees that any suggestions, ideas, information, documents or things which it
    discloses to Discloser shall not be subject to an obligation of confidentiality by Discloser, and
    Discloser shall not be liable for any use or disclosure thereof, unless there is a prior written agreement
    to the contrary between the parties.
    6.It is understood by the parties that the Confidential Information disclosed by Discloser
    to Recipient shall not be subject to this Agreement if such information:
    [a]is or becomes publicly known other than through a breach of this Agreement by
    Recipient, or
    [b]is known to Recipient prior to disclosure by Discloser, and Recipient can
    establish such prior knowledge by competent written documentation, or
    [c]is disclosed to Recipient by a third party subsequent to disclosure by Discloser,
    and such disclosure by the third party is not in violation of any confidentiality
    agreement or obligation of Discloser, or
    [d]is independently developed by employees of Recipient who have not had access
    to or received Confidential Information under this Agreement, or
    [e]is furnished to a third party by Discloser without restriction on the third party’s
    rights to disclose, or
    [f]is authorized in writing by Discloser to be released from confidentiality or non circumvention
    obligations hereunder.
    Specific information shall not be deemed to be within the foregoing exceptions merely because it is included
    within general information which is within the exceptions, nor will a combination of features be deemed to be
    within such exceptions merely because the individual features of the combination are separately included within
    the exceptions. Recipient bears the burden of proving applicability of any of the above exceptions upon which it
    intends to rely. 7.Reasonable care shall be taken by Recipient to insure compliance with the terms and conditions
    of this Agreement. “Reasonable care” shall mean the same degree of care exercised by Recipient with respect to
    its own confidential information. 8.It is expressly understood by Recipient that the disclosure by Discloser is not a
    public use or disclosure, or sale or offer for sale, of any product, equipment, process or service. 9.The parties
    agree that nothing in this Agreement shall be construed as granting any rights under any patent, copyright, or
    other intellectual property right of Discloser, nor shall this Agreement grant Recipient any rights in or to the
    Confidential Information other than the limited right to review such Con- fidential Information solely for the
    purposes defined herein. 10.If Recipient becomes legally compelled (by oral questions, interrogatories, request
    for information or docu- ments, subpoena, civil investigative demand or similar process) to disclose any
    Confidential Information, Recipi- ent will provide Discloser with prompt written notice of such process so that
    Discloser may seek a protective order, appropriate remedy and/or waive compliance with the provisions of this Agreement. In the event such
    protective order or other remedy is not obtained, or Discloser waives compliance with the provisions of this
    Agreement, Recipient will furnish only the Confidential Information that is legally required and will exercise
    reasonable efforts to obtain assurances that confidential treatment will be accorded to the Confidential Informa
    tion so disclosed.
    11.Recipient agrees that its directors, officers, employees, affiliates and/or subsidiaries will not export Confiden
    tial Information in contravention of the provisions of the U.S. Export Administration Act of 1985 and the regula
    tions issued thereunder and other relevant laws of other countries.
    12.This Agreement supersedes all previous oral and/or written agreements, if any, between the parties regarding
    confidentiality of information disclosed in connection with the Discussions.
    13.With regard to patents, trademarks and copyrights, such confidentiality, nondisclosure and non-circumven
    tion obligations shall extend through the remaining life of such intellectual properties, unless released for use by
    Discloser under a licensing agreement between the parties describing the terms and conditions of use of such
    intellectual properties. Additionally, with regard to trade secrets, such confidentiality, nondisclosure and non
    circumvention obligations shall extend indefinitely, or for a period for so long as the trade secret remains under
    the direct control of Discloser, and/or Discloser’s assigns or successors unless released for use by Discloser under
    a license agreement between the parties describing the terms and conditions of use of such trade secrets.
    14.This Agreement shall be governed by and interpreted in accordance with the laws of the State of California.
    The parties hereto consent to the jurisdiction of the courts of the State of California in all matters pertaining to
    this Agreement.
    15.Recipient’s duty to protect Confidential Information disclosed under this Agreement shall expire five (5)
    years from the date of the disclosure.
    16.This Agreement may be executed in one or more counterparts, each of which shall be deemed an original,
    but all of which together shall constitute one and the same agreement. Faxed counterparts and signatures shall be
    deemed originals and shall be as effective, valid and enforceable as originals.
    IN WITNESS WHEREOF, the parties have caused this Agreement to be executed by their duly authorized repre
    sentative, as of the day and date below written. One affixed signature on behalf of either party by an officer/direc
    tor or duly authorized representative/agent shall bind this Agreement between the parties.''',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              title: const Text('I have read and agree to the NDA terms'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agreed ? () => context.go(widget.nextRoute) : null,
                child: const Text('I Agree'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
